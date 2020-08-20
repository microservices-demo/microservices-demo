#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys

def log(msg):
    print(msg, file=sys.stderr)

def die(msg):
    print(msg, file=sys.stderr)
    exit(-1)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("jsonfile", help="Events json file")
    parser.add_argument("--event", help="Events name")
    parser.add_argument("--list", help="Events list", action="store_true")
    args = parser.parse_args()

    jsonfile = args.jsonfile
    f = open(jsonfile, 'r') if jsonfile is not None else sys.stdin
    events = json.load(f)

    if args.list:
        print('\n'.join(events['events'].keys()))
        return

    if args.event not in events["events"]:
        die(f"{args.event} not found in {jsonfile}")

    event = events["events"][args.event]
    params = sum([[f"--{k}", v] for k, v in event['params'].items()], [])
    cmds = ["./get_metrics_from_prom.py"] + params
    log(f"Running {' '.join(cmds)}...")
    subprocess.run(cmds)

if __name__ == '__main__':
    main()
