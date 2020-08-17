#!/usr/bin/env python3

import argparse
import json
import sys

STEP = 15

def die(msg):
    print(msg, file=sys.stderr)
    exit(-1)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("jsonfile", help="target JSON file", nargs='?')
    args = parser.parse_args()

    jsonfile = args.jsonfile
    f = open(jsonfile, 'r') if jsonfile is not None else sys.stdin
    data = json.load(f)

    print(f"Validating {jsonfile}...", file=sys.stderr)

    if 'containers' not in data:
        die("data should have 'containers' key")
    if 'services' not in data:
        die("data should have 'services' key")
    if 'nodes' not in data:
        die("data should have 'nodes' key")
    if 'mappings' not in data:
        die("data should have 'mappings' key")
    if 'nodes-containers' not in data['mappings']:
        die("data should have 'nodes-containers' key")

    if (got := len(data['containers'])) != 14:
        die(f"data['containers'] length should be 14, not {got}")
    for container, metrics in data['containers'].items():
        if (got := len(metrics)) < 40:
            die(f"data['containers'][<container>] length should be >= 40, not {got}")
        dupcheck = {}
        for metric in metrics:
            if (name := metric['metric_name']) in dupcheck:
                die(f"{container}/{name} is duplicated")
            else:
                dupcheck[name] = True
            start, end = metric['values'][0][0], metric['values'][-1][0]
            if abs((cnt := int((end - start) / STEP)) - (got := len(metric['values']))) > 1:
                die(f"the number of values of {name} should be {cnt}, not {got}, start: {start}, end: {end}")

    if (got := len(data['services'])) != 7:
        die(f"data['services'] length should be 7, not {got}")
    for service, metrics in data['services'].items():
        if (got := len(metrics)) != 2:
            die(f"data['services'][<service>] length should be 2, not {got}")

    if (got := len(data['nodes'])) < 3:
        die(f"data['nodes'] length should be >= 3, not {got}")
    for node, metrics in data['nodes'].items():
        if (got := len(metrics)) != 264:
            die(f"data['nodes'][<node>] length should be 264, not {got}")
        dupcheck = {}
        for metric in metrics:
            if (name := metric['metric_name']) in dupcheck:
                die(f"{container}/{name} is duplicated")
            else:
                dupcheck[name] = True
            start, end = metric['values'][0][0], metric['values'][-1][0]
            if abs((cnt := int((end - start) / STEP)) - (got := len(metric['values']))) > 1:
                die(f"the number of values of {name} should be {cnt}, not {got}, start: {start}, end: {end}")

    print("Completed!")

if __name__ == '__main__':
    main()
