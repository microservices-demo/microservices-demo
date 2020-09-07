import os
import sys
import json
import time
from datetime import datetime
import pandas as pd
import numpy as np
import re
import random
from pprint import pprint
from scipy.cluster.hierarchy import linkage
from scipy.cluster.hierarchy import fcluster
from scipy.spatial.distance import pdist, squareform
from clustering.sbd import sbd
from statsmodels.tsa.stattools import adfuller
from concurrent import futures

## Parameters ###################################################
TARGET_DATA = {"containers": "all",
               "services": "all",
               "middlewares": "all"}
PLOTS_NUM = 360
SIGNIFICANCE_LEVEL = 0.05
THRESHOLD_DIST = 0.01
#################################################################

def hierarchical_clustering(target_df, clustering_info, dist_func):
    series = target_df.values.T
    norm_series = z_normalization(series)
    dist = pdist(norm_series, metric=dist_func)
    # distance_list.extend(dist)
    dist_matrix = squareform(dist)
    z = linkage(dist, method="single", metric=dist_func)
    labels = fcluster(z, t=THRESHOLD_DIST, criterion="distance")
    cluster_dict = {}
    for i, v in enumerate(labels):
        if v not in cluster_dict:
            cluster_dict[v] = [i]
        else:
            cluster_dict[v].append(i)
    remove_list = []
    for c in cluster_dict:
        cluster_metrics = cluster_dict[c]
        if len(cluster_metrics) == 1:
            continue
        if len(cluster_metrics) == 2:
            # Select the representative metric at random
            shuffle_list = random.sample(cluster_metrics, len(cluster_metrics))
            clustering_info[target_df.columns[shuffle_list[0]]] = [target_df.columns[shuffle_list[1]]]
            remove_list.append(target_df.columns[shuffle_list[1]])
        elif len(cluster_metrics) > 2:
            # Select medoid as the representative metric
            distances = []
            for met1 in cluster_metrics:
                dist_sum = 0
                for met2 in cluster_metrics:
                    if met1 != met2:
                        dist_sum += dist_matrix[met1][met2]
                distances.append(dist_sum)
            medoid = cluster_metrics[np.argmin(distances)]
            clustering_info[target_df.columns[medoid]] = []
            for r in cluster_metrics:
                if r != medoid:
                    remove_list.append(target_df.columns[r])
                    clustering_info[target_df.columns[medoid]].append(target_df.columns[r])
    return clustering_info, remove_list

def z_normalization(data):
    arr = []
    for d in data:
        mean = d.mean()
        std = d.std()
        arr.append((d - mean) / std)
    return np.array(arr)

def count_metrics(metrics_dimension, dataframe, n):
    for col in dataframe.columns:
        if re.match("^c-", col):
            container_name = col.split("_")[0].replace("c-", "")
            if container_name not in metrics_dimension["containers"]:
                metrics_dimension["containers"][container_name] = [0, 0, 0]
            metrics_dimension["containers"][container_name][n] += 1
        elif re.match("^m-", col):
            middleware_name = col.split("_")[0].replace("m-", "")
            if middleware_name not in metrics_dimension["middlewares"]:
                metrics_dimension["middlewares"][middleware_name] = [0, 0, 0]
            metrics_dimension["middlewares"][middleware_name][n] += 1
        elif re.match("^s-", col):
            service_name = col.split("_")[0].replace("s-", "")
            if service_name not in metrics_dimension["services"]:
                metrics_dimension["services"][service_name] = [0, 0, 0]
            metrics_dimension["services"][service_name][n] += 1
        elif re.match("^n-", col):
            node_name = col.split("_")[0].replace("n-", "")
            if node_name not in metrics_dimension["nodes"]:
                metrics_dimension["nodes"][node_name] = [0, 0, 0]
            metrics_dimension["nodes"][node_name][n] += 1
    return metrics_dimension

if __name__ == '__main__':
    DATA_FILE = sys.argv[1]
    if len(sys.argv) > 2:
        PLOTS_NUM = int(sys.argv[2])
    # Prepare data matrix
    raw_data = pd.read_json(DATA_FILE)
    data_df = pd.DataFrame()
    for target in TARGET_DATA:
        for t in raw_data[target].dropna():
            for metric in t:
                if metric["metric_name"] in TARGET_DATA[target] or TARGET_DATA[target] == "all":
                    metric_name = metric["metric_name"].replace("container_", "").replace("node_", "")
                    target_name = metric[
                        "{}_name".format(target[:-1]) if target != "middlewares" else "container_name"].replace(
                        "gke-microservices-experi-default-pool-", "")
                    if re.match("^gke-microservices-experi", target_name):
                        continue
                    if target_name in ["queue-master", "rabbitmq", "session-db"]:
                        continue
                    column_name = "{}-{}_{}".format(target[0], target_name, metric_name)
                    data_df[column_name] = np.array(metric["values"], dtype=np.float)[:, 1][-PLOTS_NUM:]
    data_df = data_df.round(4)
    data_df = data_df.interpolate(method="spline", order=3, limit_direction="both")

    # Prepare list of services
    services_list = []
    for col in data_df.columns:
        if re.match("^s-", col):
            service_name = col.split("_")[0].replace("s-", "")
            if service_name not in services_list:
                services_list.append(service_name)

    # Aggregate the dimension of a metric
    metrics_dimension = {}
    for target in TARGET_DATA:
        metrics_dimension[target] = {}
    metrics_dimension = count_metrics(metrics_dimension, data_df, 0)
    metrics_dimension["total"] = [len(data_df.columns)]

    # Reduce metrics
    ## Step 1: Reduced metrics with stationarity
    start = time.time()
    reduced_by_st_df = pd.DataFrame()
    with futures.ProcessPoolExecutor(max_workers=4) as executor:
        future_to_col = {}
        for col in data_df.columns:
            data = data_df[col].values
            if data.sum() == 0. or len(np.unique(data)) == 1 or np.isnan(data.sum()):
                continue
            future_to_col[executor.submit(adfuller, data)] = col
        for future in futures.as_completed(future_to_col):
            col = future_to_col[future]
            p_val = future.result()[1]
            if not np.isnan(p_val):
                if p_val >= SIGNIFICANCE_LEVEL:
                    reduced_by_st_df[col] = data_df[col]

    metrics_dimension = count_metrics(metrics_dimension, reduced_by_st_df, 1)
    metrics_dimension["total"].append(len(reduced_by_st_df.columns))
    time_adf = round(time.time() - start, 2)

    ## Step 2: Reduced by hierarchical clustering
    start = time.time()
    clustering_info = {}
    reduced_df = reduced_by_st_df

    # Clustering metrics by service including services, containers and middlewares metrics
    for ser in services_list:
        target_df = reduced_by_st_df.loc[:, reduced_by_st_df.columns.str.startswith(
            ("s-{}_".format(ser), "c-{}".format(ser), "m-{}".format(ser)))]
        if len(target_df.columns) in [0, 1]:
            continue
        clustering_info, remove_list = hierarchical_clustering(target_df, clustering_info, sbd)
        for r in remove_list:
            reduced_df = reduced_df.drop(r, axis=1)

    metrics_dimension = count_metrics(metrics_dimension, reduced_df, 2)
    metrics_dimension["total"].append(len(reduced_df.columns))
    time_clustering = round(time.time() - start, 2)
    #pprint(metrics_dimension)

    # Output summary of results as JSON file
    summary = {}
    summary["data_file"] = DATA_FILE.split("/")[-1]
    summary["number_of_plots"] = PLOTS_NUM
    summary["execution_time"] = {"ADF": time_adf, "clustering": time_clustering, "total": round(time_adf+time_clustering, 2)}
    summary["metrics_dimension"] = metrics_dimension
    summary["reduced_metrics"] = list(reduced_df.columns)
    summary["clustering_info"] = clustering_info
    file_name = "tsifter_{}.json".format(datetime.now().strftime("%Y%m%d%H%M%S"))
    result_dir = "./results/{}".format(DATA_FILE.split("/")[-1])
    if not os.path.isdir(result_dir):
        os.makedirs(result_dir)
    with open(os.path.join(result_dir, file_name), "w") as f:
        json.dump(summary, f, indent=4)
