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
from clustering.sbd import sbd
from clustering.sbd import silhouette_score
from clustering.metricsnamecluster import cluster_words
from clustering.kshape import kshape

## Parameters ###################################################
TARGET_DATA = {"containers": "all",
               "services": "all",
               "middlewares": "all"}
PLOTS_NUM = 360
SIGNIFICANCE_LEVEL = 0.05
THRESHOLD_DIST = 0.01
#################################################################

def kshape_clustering(target_df, service_name, clustering_info, dist_func):
    data = z_normalization(target_df.values.T)
    labels = []
    scores = []
    centroids = []
    for n in np.arange(2, data.shape[0]):
        words_list = []
        for col in target_df.columns:
            words_list.append(col[2:])
        init_labels = cluster_words(words_list, service_name, n)
        results = kshape(data, n, initial_clustering=init_labels)
        label = [0] * data.shape[0]
        cluster_center = []
        cluster_num = 0
        for res in results:
            if not res[1]:
                continue
            for i in res[1]:
                label[i] = cluster_num
            cluster_center.append(res[0])
            cluster_num += 1
        if len(set(label)) == 1:
            continue
        labels.append(label)
        scores.append(silhouette_score(data, label))
        centroids.append(cluster_center)
    idx = np.argmax(scores)
    label = labels[idx]
    centroid = centroids[idx]
    n_cluster = len(np.unique(label))
    cluster_dict = {}
    remove_list = []
    for i, v in enumerate(label):
        if v not in cluster_dict:
            cluster_dict[v] = [i]
        else:
            cluster_dict[v].append(i)
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
            # Select the representative metric based on the distance from the centroid
            distances = []
            cent = centroid[c]
            for met in cluster_metrics:
                distances.append(sbd(cent, data[met]))
            representative_metric = cluster_metrics[np.argmin(distances)]
            clustering_info[target_df.columns[representative_metric]] = []
            for r in cluster_metrics:
                if r != representative_metric:
                    remove_list.append(target_df.columns[r])
                    clustering_info[target_df.columns[representative_metric]].append(target_df.columns[r])
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
                    data_df[column_name] = np.array(metric["values"], dtype=np.float)[:, 1][:PLOTS_NUM]
    data_df = data_df.round(4)

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
    ## Step 1: Reduced metrics by CV
    start = time.time()
    reduced_by_cv_df = pd.DataFrame()
    for col in data_df.columns:
        data = data_df[col].values
        mean = data.mean()
        std = data.std()
        if mean == 0. and std == 0.:
            cv = 0
        else:
            cv = std / mean
        if cv > 0.002:
            reduced_by_cv_df[col] = data_df[col]

    metrics_dimension = count_metrics(metrics_dimension, reduced_by_cv_df, 1)
    metrics_dimension["total"].append(len(reduced_by_cv_df.columns))
    time_cv = round(time.time() - start, 2)

    ## Step 2: Reduced by k-Shape
    start = time.time()
    clustering_info = {}
    reduced_df = reduced_by_cv_df

    # Clustering metrics by services including services, containers and middlewares
    for ser in services_list:
        target_df = reduced_by_cv_df.loc[:, reduced_by_cv_df.columns.str.startswith(
            ("s-{}_".format(ser), "c-{}".format(ser), "m-{}".format(ser)))]
        if len(target_df.columns) in [0, 1]:
            continue
        clustering_info, remove_list = kshape_clustering(target_df, ser, clustering_info, sbd)
        for r in remove_list:
            reduced_df = reduced_df.drop(r, axis=1)

    metrics_dimension = count_metrics(metrics_dimension, reduced_df, 2)
    metrics_dimension["total"].append(len(reduced_df.columns))
    time_clustering = round(time.time() - start, 2)
    #pprint(metrics_dimension)

    # Output summary of results as JSON file
    summary = {}
    summary["data_file"] = DATA_FILE.split("/")[-1]
    summary["execution_time"] = {"ADF": time_cv, "clustering": time_clustering, "total": time_cv+time_clustering}
    summary["metrics_dimension"] = metrics_dimension
    summary["reduced_metrics"] = list(reduced_df.columns)
    summary["clustering_info"] = clustering_info
    file_name = "sieve_{}.json".format(datetime.now().strftime("%Y%m%d%H%M%S"))
    with open(os.path.join("./results", file_name), "w") as f:
        json.dump(summary, f, indent=4)
