#!/usr/bin/env python3

import argparse
import concurrent.futures
import datetime
import json
import urllib.request
import time

COMPONENT_LABELS = {"front-end", "orders", "orders-db", "carts", "cards-db", "shipping","user", "user-db", "payment", "catalogue", "queue-master", "rabbitmq"}
STEP = 15

def get_targets(url):
    params = {
        "match_target": '{job="kubernetes-cadvisor"}',
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

def get_series(url, targets, start, end, step):
    start = start - start % step
    end = end - end % step

    future_to_params = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        for target in targets:
            query = '{0}{{namespace="sock-shop",container=~"{1}"}}'.format(
                    target['metric'], '|'.join(COMPONENT_LABELS))
            if target['type'] == 'counter':
                query = 'rate({}[1m])'.format(query)
            params = {
                "query": query,
                "start": start,
                "end": end,
                "step": '{}s'.format(step),
            }
            future_to_params[executor.submit(request_query, url, params)] = params

    series = []
    for future in concurrent.futures.as_completed(future_to_params):
        params = future_to_params[future]
        res = future.result()
        if res is not None:
            series.append(res)
    return series

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

    targets = get_targets(args.prometheus_url)
    series = get_series(args.prometheus_url, targets, args.start, args.end, args.step)
    print(json.dumps(series, sort_keys=True))

if __name__ == '__main__':
    main()
