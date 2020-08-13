#!/usr/bin/env python3

import argparse
import concurrent.futures
import datetime
import json
import urllib.request
import sys
import time

COMPONENT_LABELS = {"front-end", "orders", "orders-db", "carts", "carts-db", "shipping", "user", "user-db", "payment", "catalogue", "catalogue-db", "queue-master", "rabbitmq"}
STEP = 15

def get_targets(url, job):
    params = {
        "match_target": '{{job="{}"}}'.format(job),
    }
    req = urllib.request.Request('{}{}?{}'.format(url, "/api/v1/targets/metadata",
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

def request_query(url, params, target):
    params = urllib.parse.urlencode(params).encode('ascii')
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
    }
    try:
        req = urllib.request.Request(url=url+'/api/v1/query',
            data=params, headers=headers)
        with urllib.request.urlopen(req) as res:
            body = json.load(res)
            result = body['data']['result']
            if result is not None and len(result) > 0:
                return result
    except urllib.error.HTTPError as err:
        print(urllib.parse.unquote(params.decode()), file=sys.stderr)
        print(err.read().decode(), file=sys.stderr)
        raise(err)
    except urllib.error.URLError as err:
        print(err.reason, file=sys.stderr)
        raise(err)
    except Exception as e:
        raise(e)

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
    start = start - start % step
    end = end - end % step

    futures = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        for target in targets:
            if target == 'node_cpu_seconds_total':
                selector += ',mode!="idle"'
            query = '{0}{{{1}}}'.format(target['metric'], selector)
            if target['type'] == 'counter':
                query = 'rate({}[1m])'.format(query)
            query = 'sum by (instance,job,node,container)({})'.format(query)
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
    start = start - start % step
    end = end - end % step
    params = {
        "query": query,
        "start": start,
        "end": end,
        "step": '{}s'.format(step),
    }
    return request_query_range(url, params, target)

def print_metrics_as_json(container_metrics, node_metrics, throughput_metrics, latency_metrics):
    """
    An example of JSON
    {
      'containers': {
        'orders-db': [
          { 'container_name': 'orders-db', 'metric_name': 'xx', 'values': [<timestamp>, <value>] },
             ...
        ]
        ...
      ]
      'services': {
        'orders': [
          { 'service_name': 'orders-db', 'metric_name': 'xx', 'values': [<timestamp>, <value>] } },
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
         nodes-containers': {
           '<container name>': [
           ]
         }
      }
    }
    """

    data = {'containers': {}, 'nodes':{}, 'services': {}}
    for metric in container_metrics:
        # some metrics in results of prometheus query has no '__name__'
        if '__name__' not in metric['metric']:
            continue
        container = metric['metric']['container']
        data['containers'].setdefault(container, [])
        m = {
            'container_name': container,
            'metric_name': metric['metric']['__name__'],
            'values': metric['values'],
        }
        data['containers'][container].append(m)
    for metric in node_metrics:
        # some metrics in results of prometheus query has no '__name__'
        if '__name__' not in metric['metric']:
            continue
        node = metric['metric']['node']
        data['nodes'].setdefault(node, [])
        m = {
            'node_name': node,
            'metric_name': metric['metric']['__name__'],
            'values': metric['values'],
        }
        data['nodes'][node].append(m)
    for metric in throughput_metrics:
        service = metric['metric']['name']
        data['services'].setdefault(service, [])
        m = {
            'service_name': metric['metric']['name'],
            'metric_name': 'throughput',
            'values': metric['values'],
        }
        data['services'][service].append(m)
    for metric in latency_metrics:
        service = metric['metric']['name']
        data['services'].setdefault(service, [])
        m = {
            'service_name': metric['metric']['name'],
            'metric_name': 'latency',
            'values': metric['values'],
        }
        data['services'][service].append(m)

    print(json.dumps(data))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prometheus-url", help="endpoint URL for prometheus server",
                                default="http://localhost:9090")
    parser.add_argument("--start", help="start epoch time", type=int)
    parser.add_argument("--end", help="end epoch time", type=int)
    parser.add_argument("--step", help="step seconds", type=int, default=STEP)
    parser.add_argument("--duration", help="", type=str, default="60m")
    args = parser.parse_args()

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
    if start > end:
        print("start must be lower than end.", file=sys.stderr)
        parser.print_help()

    # get container metrics (cAdvisor)
    container_targets = get_targets(args.prometheus_url, "kubernetes-cadvisor")
    container_selector = 'namespace="sock-shop",container=~"{}"'.format('|'.join(COMPONENT_LABELS))
    container_metrics = get_metrics(args.prometheus_url, container_targets, start, end, args.step, container_selector)

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
    print_metrics_as_json(container_metrics, node_metrics, throughput_metrics, latency_metrics)

if __name__ == '__main__':
    main()
