import csv
import requests
import json
import os

def collection(time, step, source, filename, tag, now_unix):
    """
    time: time in minutes
    step: query interval within the timeframe in seconds
    source: json file with the metrics to collect
    filename: created csv file will have this name
    tag: locust tags to execute
    """
    file = open(source)
    metrics = json.load(file)['data']

    #quick'n dirty bool to add timestamps to only first iteration
    first = True
    for metric in metrics:
        response = requests.get(
            'http://localhost:9090/api/v1/query_range',
            params={
                'query': metric,
                'start': now_unix - 60 * time,
                "end": now_unix,
                'step': step
            }
        )


        results = response.json()['data']['result']

        

        labelnames = set()
        for result in results:
            labelnames.update(result['metric'].keys())
        labelnames = sorted(labelnames)
        
        with open("generated_csvs_2/" + str(tag) + "/" + str(filename) + ".csv", mode = "w") as f:
            writer = csv.writer(f, lineterminator='\n')
            if(first):
                first = False
                timestamps = []
                for x in results[0]['values']:
                    timestamps.append(x[0])
                writer.writerow(["identifier"] + timestamps)
            
            for result in results:
                vals = [x[1] for x in result['values']]
                identifier_string = ""
                for label in labelnames: 
                    identifier_string += result['metric'].get(label, '') + '&'
                    
                writer.writerow([identifier_string[:-1]] + vals)

#collection(11, 5, "./metrics.json","400U_20R_60s","carts")