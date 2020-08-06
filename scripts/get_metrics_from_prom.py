#!/usr/bin/env python3

import argparse
import concurrent.futures
import datetime
import json
import urllib.request
import time

COMPONENT_LABELS = {"front-end", "orders", "orders-db", "carts", "cards-db", "shipping", "user", "user-db", "payment", "catalogue", "catalogue-db", "queue-master", "rabbitmq"}
STEP = 15

def get_targets(url, job):
    params = {
        "match_target": '{{job="{}"}}'.format(job),
    }
    req = urllib.request.Request('{}{}?{}'.format(url, "/api/v1/targets/metadata",
        urllib.parse.urlencode(params)))
    with urllib.request.urlopen(req) as res:
        body = json.load(res)
        targets = [ {"metric": item["metric"], "type": item["type"]} for item in body["data"] ]
        return targets

def request_query(url, params):
    params = urllib.parse.urlencode(params).encode('ascii')
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
    }
    try:
        req = urllib.request.Request(url=url+'/api/v1/query_range',
            data=params, headers=headers)
        with urllib.request.urlopen(req) as res:
            body = json.load(res)
            result = body['data']['result']
            if result is not None and len(result) > 0:
                return result
    except urllib.error.HTTPError as err:
        print(urllib.parse.unquote(params.decode()))
        print(err.read().decode())
        raise(err)
    except urllib.error.URLError as err:
        print(err.reason)
        raise(err)
    except Exception as e:
        raise(e)

def get_metrics(url, targets, start, end, step, selector):
    start = start - start % step
    end = end - end % step

    future_to_params = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        for target in targets:
            query = '{0}{{{1}}}'.format(target['metric'], selector)
            if target['type'] == 'counter':
                query = 'rate({}[1m])'.format(query)
            params = {
                "query": query,
                "start": start,
                "end": end,
                "step": '{}s'.format(step),
            }
            future_to_params[executor.submit(request_query, url, params)] = params

    metrics = []
    for future in concurrent.futures.as_completed(future_to_params):
        params = future_to_params[future]
        res = future.result()
        if res is not None:
            metrics += res
    return metrics

def get_metrics_by_query(url, start, end, step, query):
    start = start - start % step
    end = end - end % step
    params = {
        "query": query,
        "start": start,
        "end": end,
        "step": '{}s'.format(step),
    }
    return request_query(url, params)

def print_metrics_as_json(container_metrics, throughput_metrics, latency_metrics):
    """
    {
      'containers': {
        'orders-db': [
          { container_name: 'orders-db', 'metric_name': 'xx', 'values': [<timestamp>, <value>] },
             ...
        ]
        ...
      ]
      'services': {
        'orders': [
          { service_name: 'orders-db', 'metric_name': 'xx', 'values': [<timestamp>, <value>] } },
          ...
        ]
        ...
      }
    }
    """

    data = {'containers': {}, 'services': {}}
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

    print(json.dumps(data, sort_keys=True))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prometheus-url", help="endpoint URL for prometheus server",
                                default="http://localhost:9090")
    now = datetime.datetime.now()
    start = now - datetime.timedelta(minutes=30) # now - 30minutes
    parser.add_argument("--start", help="start epoch time", type=int,
                                default=start.timestamp())
    parser.add_argument("--end", help="end epoch time", type=int,
                                default=now.timestamp())
    parser.add_argument("--step", help="step seconds", type=int,
                                default=STEP)
    args = parser.parse_args()

    container_targets = get_targets(args.prometheus_url, "kubernetes-cadvisor")
    container_selector = 'namespace="sock-shop",container=~"{}"'.format('|'.join(COMPONENT_LABELS))
    container_metrics = get_metrics(args.prometheus_url, container_targets, args.start, args.end, args.step, container_selector)

    throughput_metrics = get_metrics_by_query(
        args.prometheus_url, args.start, args.end, args.step,
            'sum by (name) (rate(request_duration_seconds_count{job="kubernetes-service-endpoints",kubernetes_namespace="sock-shop"}[1m]))',
    )
    latency_metrics = get_metrics_by_query(
        args.prometheus_url, args.start, args.end, args.step,
        'sum by (name) (rate(request_duration_seconds_sum{job="kubernetes-service-endpoints",kubernetes_namespace="sock-shop"}[1m])) / sum by (name) (rate(request_duration_seconds_count{job="kubernetes-service-endpoints",kubernetes_namespace="sock-shop"}[1m]))',
    )
    print_metrics_as_json(container_metrics, throughput_metrics, latency_metrics)

if __name__ == '__main__':
    main()
