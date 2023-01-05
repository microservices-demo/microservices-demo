import json
import csv
import requests
from datetime import datetime, timedelta 
from time import mktime
    
def query_csv_timeseries(q, time, step, filename):

    #generate timestamp + query
    now = datetime.now()
    now_unix =  mktime(now.timetuple())

    response = requests.get('http://localhost:9090/api/v1/query_range',
            params= {'query': q, 'start': now_unix - 3600 * time, "end": now_unix, "step": step})
    results = response.json()['data']['result']
    # Build a list of all labelnames used.
    labelnames = set()
    for result in results:
        labelnames.update(result['metric'].keys())


    # Canonicalize
    labelnames = sorted(labelnames)
    # print(labelnames)
    # print(result["values"])

    # with open( q + "_" + state + '.csv', mode='a') as f:
    with open(filename + '.csv', mode='a') as f:
        writer = csv.writer(f)
        # Write the header,
        #writer.writerow(labelnames)

        #Write the samples.
        for result in results:
            l = [result['metric'].get('__name__', '')] + result['values']
            
            #Prune the first element in each list, which is just a unix timestamp
            vals = [x[1] for x in result['values']]
            identifier_string = ""
            for label in labelnames:
                identifier_string += result['metric'].get(label, '') + "&"
                #l.append(result['metric'].get(label, ''))
                #writer.writerow(l)
                #print(l , "lllllll")
            #for label in labelnames:
                
            writer.writerow([identifier_string[:-1]] + vals)

def query_collection(time, step, source, filename):
    file = open(source)
    metrics = json.load(file)['data']

    for i in metrics:
        query_csv_timeseries(i, time, step, filename)