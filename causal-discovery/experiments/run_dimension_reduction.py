#!/usr/bin/env python3

import argparse
import json
import os
import multiprocessing
import subprocess
import sys

CUR_DIR = os.fspath(os.path.dirname(__file__))
DATA_DIR = f"{CUR_DIR}/../../data/"
INPUT = {
    'user-db': {
        'cpu-load': f"{DATA_DIR}/20200831_user-db_cpu-load_02.json",
        'network-latency': f"{DATA_DIR}/20200901_user-db_network-latency_01.json",
    },
    'shipping': {
        'cpu-load': f"{DATA_DIR}/20200902_shipping_cpu-load_01.json",
        'network-latency': f"{DATA_DIR}/20200902_shipping_network-latency_01.json",
    },
}

def log(msg):
    print(msg, file=sys.stderr)

def run(method, num_cores, output):
    for container, entries in INPUT.items():
        for anomaly, inputfile in entries.items():
            log(f"Running {method} test in case of {container} {anomaly} {inputfile} ...")

            cmdout = subprocess.Popen(f"{CUR_DIR}/../{method}.py --max-workers {num_cores} {inputfile}",
                    shell=True, stdout=subprocess.PIPE)
            jsonS, _ = cmdout.communicate()
            res = json.loads(jsonS)['metrics_dimension']
            before_num_metrics = res['total'][0]
            filtered_num_metrics = res['total'][1]
            last_num_metrics = res['total'][2]

            output[method]['reduction'].setdefault(container, {})
            output[method]['reduction'][container].setdefault(anomaly, {})
            output[method]['reduction'][container][anomaly]['before_num_metrics'] = before_num_metrics
            output[method]['reduction'][container][anomaly]['filtered_num_metrics'] = filtered_num_metrics
            output[method]['reduction'][container][anomaly]['last_num_metrics'] = last_num_metrics


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--method", help="'tsifter' or 'sieve'", default='all')
    parser.add_argument("--num-cores", help="number of CPU cores",
        type=int, default=multiprocessing.cpu_count())
    args = parser.parse_args()

    output = {
        'tsifter': {
            'reduction': {},
        },
        'sieve': {
            'reduction': {},
        }
    }

    if args.method in ['all', 'tsifter']:
        run('tsifter', args.num_cores, output)
    if args.method in ['all', 'sieve']:
        run('sieve', args.num_cores, output)

    json.dump(output, sys.stdout, indent=4)
