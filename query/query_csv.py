import csv
import requests
import sys

"""
A simple program to print the result of a Prometheus query as CSV.
"""

if len(sys.argv) != 3:
    print('Usage: {0} http://prometheus:9090 a_query'.format(sys.argv[0]), sys.argv[1])
    print('argvs: ', sys.argv)
    sys.exit(1)

response = requests.get('{0}/api/v1/query'.format(sys.argv[1]),
        params={'query': sys.argv[2]})
results = response.json()['data']['result']

# Build a list of all labelnames used.
labelnames = set()
for result in results:
    labelnames.update(result['metric'].keys())

# Canonicalize
labelnames.discard('__name__')
labelnames = sorted(labelnames)

with open('test.csv', mode='x') as f:
    writer = csv.writer(f)
    # Write the header,
    writer.writerow(['name', 'timestamp', 'value'] + labelnames)

    # Write the samples.
    for result in results:
        l = [result['metric'].get('__name__', '')] + result['value']
        for label in labelnames:
            l.append(result['metric'].get(label, ''))
        writer.writerow(l)
