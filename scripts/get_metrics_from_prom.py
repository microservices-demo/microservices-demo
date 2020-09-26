#!/usr/bin/env python3

""" An example of JSON layout
    {
      'containers': {
        '<container name>': [
          { 'container_name': '<container name>', 'metric_name': 'xx', 'values': [<timestamp>, '<value>'] },
             ...
        ]
        ...
      ]
      'middlewares': {
        '<container name>': [
          [ {'container_name': '<container name>'}, 'metric_name': 'xx', 'values': [<timestamp>, '<value>']],
        ],
      },
      'services': {
        '<service name>': [
          { 'service_name': '<container name>', 'metric_name': 'xx', 'values': [<timestamp>, '<value>'] } },
          ...
        ]
        ...
      },
      'nodes': {
        '<node name>': [
          [ {'node_name': 'xxx'}, 'metric_name': 'xx', 'values': [<timestamp>, <value>]],
        ],
      },
      'mappings': {
         'nodes-containers': {
           '<node name>': [ '<container name>', ... ]
         }
      }
    }
"""

import argparse
import concurrent.futures
import datetime
import json
import urllib.request
import sys

COMPONENT_LABELS = {"front-end", "orders", "orders-db", "carts", "carts-db", "shipping", "user", "user-db", "payment", "catalogue", "catalogue-db", "queue-master", "rabbitmq"}
STEP = 5
NAN = 'nan'

PROM_GRAFANA = {
    'http://prometheus01.prv': 'http://grafana01.prv',
    'http://prometheus02.prv': 'http://grafana02.prv',
}
GRAFANA_DASHBOARD = "d/3cHU4RSMk/sock-shop-performance"


def get_targets(url, job):
    params = {
        "match_target": '{{job=~"{}"}}'.format(job),
    }
    req = urllib.request.Request('{}{}?{}'.format(
        url, "/api/v1/targets/metadata",
        urllib.parse.urlencode(params)))
    dupcheck = {}
    targets = []
    with urllib.request.urlopen(req) as res:
        body = json.load(res)
        # remove duplicate target
        for item in body["data"]:
            if item["metric"] not in dupcheck:
                targets.append({"metric": item["metric"], "type": item["type"]})
                dupcheck[item["metric"]] = 1
        return targets


def request_query_range(url, params, target):
    bparams = urllib.parse.urlencode(params).encode('ascii')
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
    }
    try:
        # see https://prometheus.io/docs/prometheus/latest/querying/api/#range-queries
        req = urllib.request.Request(url=url+'/api/v1/query_range',
            data=bparams, headers=headers)
        with urllib.request.urlopen(req) as res:
            body = json.load(res)
            metrics = body['data']['result']
            if metrics is None or len(metrics) < 1:
                return []
            for metric in metrics:
                metric['metric']['__name__'] = target['metric']
            return metrics
    except urllib.error.HTTPError as err:
        print(urllib.parse.unquote(bparams.decode()), file=sys.stderr)
        print(err.read().decode(), file=sys.stderr)
        raise(err)
    except urllib.error.URLError as err:
        print(err.reason, file=sys.stderr)
        raise(err)
    except Exception as e:
        raise(e)


def get_metrics(url, targets, start, end, step, selector):
    futures = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        for target in targets:
            if target == 'node_cpu_seconds_total':
                selector += ',mode!="idle"'
            query = '{0}{{{1}}}'.format(target['metric'], selector)
            if target['type'] == 'counter':
                query = 'rate({}[1m])'.format(query)
            query = 'sum by (instance,job,node,container,pod)({})'.format(query)
            params = {
                "query": query,
                "start": start,
                "end": end,
                "step": '{}s'.format(step),
            }
            futures.append(executor.submit(request_query_range, url, params, target))
        executor.shutdown()

    concated_metrics = []
    for future in concurrent.futures.as_completed(futures):
        metrics = future.result()
        if metrics is None:
            continue
        concated_metrics += metrics
    return concated_metrics


def get_metrics_by_query_range(url, start, end, step, query, target):
    params = {
        "query": query,
        "start": start,
        "end": end,
        "step": '{}s'.format(step),
    }
    return request_query_range(url, params, target)


def interpotate_time_series(values, time_meta):
    start, end, step = time_meta['start'], time_meta['end'], time_meta['step']
    new_values = []

    # start check
    if (lost_num := int((values[0][0] - start) / step)-1) > 0:
        for j in range(lost_num):
            new_values.append([start + step*j, NAN])

    for i, val in enumerate(values):
        if i+1 >= len(values):
            new_values.append(val)
            break
        cur_ts, next_ts = val[0], values[i+1][0]
        new_values.append(val)
        if (lost_num := int((next_ts - cur_ts) / step)-1) > 0:
            for j in range(lost_num):
                new_values.append([cur_ts + step*(j+1), NAN])

    # end check
    last_ts = values[-1][0]
    if (lost_num := int((end - last_ts)/ step)) > 0:
        for j in range(lost_num):
            new_values.append([last_ts + step*(j+1), NAN])

    return new_values


def support_set_default(obj):
    if isinstance(obj, set):
        return list(obj)
    raise TypeError(repr(obj) + " is not JSON serializable")


def metrics_as_result(container_metrics, pod_metrics, node_metrics, throughput_metrics, latency_metrics, time_meta):
    grafana_url = PROM_GRAFANA[time_meta['prometheus_url']]
    start, end = time_meta['start'], time_meta['end']
    data = {
        'meta': {
            'prometheus_url': time_meta['prometheus_url'],
            'grafana_url': grafana_url,
            'grafana_dashboard_url': f"{grafana_url}/{GRAFANA_DASHBOARD}?orgId=1&from={start}000&to={end}000",
            'start': start,
            'end': end,
            'step': time_meta['step'],
            'count': {
                'sum': 0,
                'containers': 0,
                'middlewares': 0,
                'services': 0,
                'nodes': 0,
            }
        },
        'mappings': {'nodes-containers': {}},
        'containers': {}, 'middlewares': {}, 'nodes': {}, 'services': {},
    }

    dupcheck = {}
    for metric in container_metrics:
        # some metrics in results of prometheus query has no '__name__'
        labels = metric['metric']
        if '__name__' not in labels:
            continue
        # ex. pod="queue-master-85f5644bf5-wrp7q"
        container = labels['pod'].rsplit("-", maxsplit=2)[0] if 'pod' in labels else labels['container']
        data['containers'].setdefault(container, [])
        metric_name = labels['__name__']

        values = interpotate_time_series(metric['values'], time_meta)
        m = {
            'container_name': container,
            'metric_name': metric_name,
            'values': values,
        }

        # 1. {container: 'POD'} => {container: 'xxx' } -> Update 'POD'
        # 2. {container: 'xxx'} => {container: 'POD' } -> Discard 'POD'
        # 3. {container: 'POD'}
        dupcheck.setdefault(container, {})
        dupcheck[container][metric_name] = False
        if labels['container'] == 'POD':
            if not dupcheck[container][metric_name]:
                data['containers'][container].append(m)
        else:
            if not dupcheck[container][metric_name]:
                uniq_metrics = [x for x in data['containers'][container] if x['metric_name'] != metric_name]
                uniq_metrics.append(m)
                data['containers'][container] = uniq_metrics
                dupcheck[container][metric_name] = True

        # Update mappings for nods and containers
        data['mappings']['nodes-containers'].setdefault(labels['instance'], set())
        data['mappings']['nodes-containers'][labels['instance']].add(container)

    for metric in pod_metrics:
        if '__name__' not in metric['metric']:
            continue
        container = metric['metric']['job'].split('/')[1]
        data['middlewares'].setdefault(container, [])
        values = interpotate_time_series(metric['values'], time_meta)
        m = {
            'container_name': container,
            'metric_name': metric['metric']['__name__'],
            'values': values,
        }
        data['middlewares'][container].append(m)

    for metric in node_metrics:
        # some metrics in results of prometheus query has no '__name__'
        if '__name__' not in metric['metric']:
            continue
        node = metric['metric']['node']
        data['nodes'].setdefault(node, [])
        values = interpotate_time_series(metric['values'], time_meta)
        m = {
            'node_name': node,
            'metric_name': metric['metric']['__name__'],
            'values': values,
        }
        data['nodes'][node].append(m)

    for metric in throughput_metrics:
        service = metric['metric']['name']
        data['services'].setdefault(service, [])
        values = interpotate_time_series(metric['values'], time_meta)
        m = {
            'service_name': metric['metric']['name'],
            'metric_name': 'throughput',
            'values': values,
        }
        data['services'][service].append(m)

    for metric in latency_metrics:
        service = metric['metric']['name']
        data['services'].setdefault(service, [])
        values = interpotate_time_series(metric['values'], time_meta)
        m = {
            'service_name': metric['metric']['name'],
            'metric_name': 'latency',
            'values': values,
        }
        data['services'][service].append(m)

    # Count the number of metric series.
    containers_cnt, middlewares_cnt, services_cnt, nodes_cnt = 0, 0, 0, 0
    for metrics in data['containers'].values():
        containers_cnt += len(metrics)
    for metrics in data['middlewares'].values():
        middlewares_cnt += len(metrics)
    for metrics in data['services'].values():
        services_cnt += len(metrics)
    for metrics in data['nodes'].values():
        nodes_cnt += len(metrics)
    data['meta']['count']['containers'] = containers_cnt
    data['meta']['count']['middlewares'] = middlewares_cnt
    data['meta']['count']['services'] = services_cnt
    data['meta']['count']['nodes'] = nodes_cnt
    data['meta']['count']['sum'] = containers_cnt + middlewares_cnt + services_cnt + nodes_cnt

    return data


def time_range_from_args(args):
    duration = datetime.timedelta(seconds=0)
    dt = args.duration
    if dt.endswith("s") or dt.endswith("sec"):
        duration = datetime.timedelta(seconds=int(dt[:-1]))
    elif dt.endswith("m") or dt.endswith("min"):
        duration = datetime.timedelta(minutes=int(dt[:-1]))
    elif dt.endswith("h") or dt.endswith("hours"):
        duration = datetime.timedelta(hours=int(dt[:-1]))
    else:
        parser.print_help()
        exit(-1)
    duration = int(duration.total_seconds())

    now = int(datetime.datetime.now().timestamp())
    start, end = now - duration, now
    if args.end is None and args.start is None:
        pass
    elif args.end is not None and args.start is None:
        end = args.end
        start = end - duration
    elif args.end is None and args.start is not None:
        start = args.start
        end = start + duration
    elif args.end is not None and args.start is not None:
        start, end = args.start, args.end
    else:
        raise("not reachable")

    start = start - start % args.step
    end = end - end % args.step
    return start, end


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prometheus-url", help="endpoint URL for prometheus server",
                                default="http://localhost:9090")
    parser.add_argument("--start", help="start epoch time", type=int)
    parser.add_argument("--end", help="end epoch time", type=int)
    parser.add_argument("--step", help="step seconds", type=int, default=STEP)
    parser.add_argument("--duration", help="", type=str, default="30m")
    args = parser.parse_args()

    start, end = time_range_from_args(args)
    if start > end:
        print("start must be lower than end.", file=sys.stderr)
        parser.print_help()

    # get container metrics (cAdvisor)
    container_targets = get_targets(args.prometheus_url, "kubernetes-cadvisor")
    container_selector = 'namespace="sock-shop",container=~"{}|POD"'.format('|'.join(COMPONENT_LABELS))
    container_metrics = get_metrics(args.prometheus_url, container_targets, start, end, args.step, container_selector)

    # get pod metrics
    pod_targets = get_targets(args.prometheus_url, "sock-shop/.*")
    pod_selector = 'job=~"sock-shop/.*"'
    pod_metrics = get_metrics(args.prometheus_url, pod_targets, start, end, args.step, pod_selector)

    # get node metrics (node-exporter)
    node_targets = get_targets(args.prometheus_url, "monitoring/")
    node_selector = 'job="monitoring/"'
    node_metrics = get_metrics(args.prometheus_url, node_targets, start, end, args.step, node_selector)

    # get service metrics
    throughput_metrics = get_metrics_by_query_range(
        args.prometheus_url, start, end, args.step,
            'sum by (name) (rate(request_duration_seconds_count{job="kubernetes-service-endpoints",kubernetes_namespace="sock-shop"}[1m]))',
            {'metric': 'request_duration_seconds_count', 'type': 'gauge'},
    )
    latency_metrics = get_metrics_by_query_range(
        args.prometheus_url, start, end, args.step,
        'sum by (name) (rate(request_duration_seconds_sum{job="kubernetes-service-endpoints",kubernetes_namespace="sock-shop"}[1m])) / sum by (name) (rate(request_duration_seconds_count{job="kubernetes-service-endpoints",kubernetes_namespace="sock-shop"}[1m]))',
        {'metric': 'request_duration_seconds_sum', 'type': 'gauge'},
    )

    result = metrics_as_result(container_metrics, pod_metrics, node_metrics, throughput_metrics, latency_metrics, {
        'start': start,
        'end': end,
        'step': args.step,
        'prometheus_url': args.prometheus_url,
    })

    print(json.dumps(result, default=support_set_default))


if __name__ == '__main__':
    main()
