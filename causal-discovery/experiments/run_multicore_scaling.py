#!/usr/bin/env python3

import argparse
import multiprocessing
import json
import os
import subprocess
import sys

CUR_DIR = os.fspath(os.path.dirname(__file__))
DATA_FILE = f"{CUR_DIR}/../../data/20200831_user-db_cpu-load_02.json"

def log(msg):
    print(msg, file=sys.stderr)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--method", help="'tsifter' or 'sieve'", default='all')
    parser.add_argument("--num-cores", help="number of CPU cores",
        type=int, default=multiprocessing.cpu_count())
    parser.add_argument("--num-test", help="number of test", type=int, default=5)
    args = parser.parse_args()

    output = {
        'tsifter': {
            'execution_time': { 'cpu_cores': {}, },
        },
        'sieve': {
            'execution_time': { 'cpu_cores': {}, },
        }
    }

    if args.method in ['all', 'tsifter']:
        for n in range(1, args.num_cores+1):
            log(f"Running tsifter test in case of CPU cores {str(n)} ...")

            total_time_sum, filtering_time_sum, clustering_time_sum = 0.0, 0.0, 0.0
            for i in range(1, args.num_test):
                log(f"Running tsifter test in case of CPU cores {str(n)}: test:f{str(i)} ...")

                cmdout = subprocess.Popen(f"{CUR_DIR}/../tsifter.py --max-workers {str(n)} {DATA_FILE}",
                    shell=True, stdout=subprocess.PIPE)
                jsonS, _ = cmdout.communicate()
                res = json.loads(jsonS)['execution_time']
                total_time_sum += res['total']
                filtering_time_sum += res['ADF']
                clustering_time_sum += res['clustering']
            output['tsifter']['execution_time']['cpu_cores'][n] = {
                'total_time': total_time_sum / args.num_test,
                'filtering_time': filtering_time_sum / args.num_test,
                'clustering_time': clustering_time_sum / args.num_test,
            }

    if args.method in ['all', 'sieve']:
        for n in range(1, args.num_cores+1):
            log(f"Running sieve test in case of CPU cores {str(n)} ...")

            total_time_sum, filtering_time_sum, clustering_time_sum = 0.0, 0.0, 0.0
            for i in range(1, args.num_test):
                log(f"Running sieve test in case of CPU cores {str(n)}: test:f{str(i)} ...")

                cmdout = subprocess.Popen(f"{CUR_DIR}/../sieve.py --max-workers {str(n)} {DATA_FILE}",
                    shell=True, stdout=subprocess.PIPE)
                jsonS, _ = cmdout.communicate()
                res = json.loads(jsonS)['execution_time']
                total_time_sum += res['total']
                filtering_time_sum += res['ADF']
                clustering_time_sum += res['clustering']
            output['tsifter']['execution_time']['cpu_cores'][n] = {
                'total_time': total_time_sum / args.num_test,
                'filtering_time': filtering_time_sum / args.num_test,
                'clustering_time': clustering_time_sum / args.num_test,
            }

    json.dump(outout, sys.stdout, indent=4)
