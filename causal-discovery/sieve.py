#!/usr/bin/env python3

import argparse
import os

# Disable multithreading in numpy.
# see https://stackoverflow.com/questions/30791550/limit-number-of-threads-in-numpy
os.environ["OMP_NUM_THREADS"] = "1"
os.environ["OPENBLAS_NUM_THREADS"] = "1"
os.environ["MKL_NUM_THREADS"] = "1"
os.environ["VECLIB_MAXIMUM_THREADS"] = "1"
os.environ["NUMEXPR_NUM_THREADS"] = "1"

import sys
import json
import time
from datetime import datetime
import pandas as pd
import numpy as np
import re
import random
from util import util
from pprint import pprint
from clustering.sbd import sbd
from clustering.sbd import silhouette_score
from clustering.metricsnamecluster import cluster_words
from clustering.kshape import kshape
from concurrent import futures

## Parameters ###################################################
TARGET_DATA = {"containers": "all",
               "services": "all",
               "middlewares": "all"}
PLOTS_NUM = 360
SIGNIFICANCE_LEVEL = 0.05
THRESHOLD_DIST = 0.01
#################################################################

def create_clusters(data, columns, service_name, n):
    words_list = [col[2:] for col in columns]
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
        return None
    return (label, silhouette_score(data, label), cluster_center)

def select_representative_metric(data, cluster_metrics, columns, centroid):
    clustering_info = {}
    remove_list = []
    if len(cluster_metrics) == 1:
        return None, None
    if len(cluster_metrics) == 2:
        # Select the representative metric at random
        shuffle_list = random.sample(cluster_metrics, len(cluster_metrics))
        clustering_info[columns[shuffle_list[0]]] = [columns[shuffle_list[1]]]
        remove_list.append(columns[shuffle_list[1]])
    elif len(cluster_metrics) > 2:
        # Select the representative metric based on the distance from the centroid
        distances = []
        for met in cluster_metrics:
            distances.append(sbd(centroid, data[met]))
        representative_metric = cluster_metrics[np.argmin(distances)]
        clustering_info[columns[representative_metric]] = []
        for r in cluster_metrics:
            if r != representative_metric:
                remove_list.append(columns[r])
                clustering_info[columns[representative_metric]].append(columns[r])
    return (clustering_info, remove_list)

def kshape_clustering(target_df, service_name, executor):
    future_list = []

    data = util.z_normalization(target_df.values.T)
    for n in np.arange(2, data.shape[0]):
        future_list.append(
            executor.submit(create_clusters, data, target_df.columns, service_name, n)
        )
    labels, scores, centroids = [], [], []
    for future in futures.as_completed(future_list):
        cluster = future.result()
        if cluster is None:
            continue
        labels.append(cluster[0])
        scores.append(cluster[1])
        centroids.append(cluster[2])

    idx = np.argmax(scores)
    label = labels[idx]
    centroid = centroids[idx]
    cluster_dict = {}
    for i, v in enumerate(label):
        if v not in cluster_dict:
            cluster_dict[v] = [i]
        else:
            cluster_dict[v].append(i)

    future_list = []
    for c, cluster_metrics in cluster_dict.items():
        future_list.append(
            executor.submit(select_representative_metric, data, cluster_metrics, target_df.columns, centroid[c])
        )
    clustering_info = {}
    remove_list = []
    for future in futures.as_completed(future_list):
        c_info, r_list = future.result()
        if c_info is None:
            continue
        clustering_info.update(c_info)
        remove_list.extend(r_list)

    return clustering_info, remove_list

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("datafile", help="metrics JSON data file")
    parser.add_argument("--max-workers", help="number of processes", type=int, default=1)
    parser.add_argument("--plot-num", help="number of plots", type=int, default=PLOTS_NUM)
    parser.add_argument("--metric-num", help="number of metrics (for experiment)", type=int, default=None)
    args = parser.parse_args()

    DATA_FILE = args.datafile
    PLOTS_NUM = args.plot_num
    METRIC_NUM = args.metric_num
    max_workers = args.max_workers

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

    # Increase the number of metrics by copying columns for experiment
    if METRIC_NUM:
        large_df = data_df
        i = 1
        while True:
            rename_columns = {}
            for col_name in data_df.columns:
                target_name = col_name.split("_")[0][2:]
                if "-" in target_name:
                    renamed = target_name.replace("-", str(i) + "-")
                else:
                    renamed = target_name + str(i)
                rename_columns[col_name] = col_name.replace(target_name, renamed)
            large_df = pd.concat([large_df, data_df.rename(columns=rename_columns)], axis=1)
            i += 1
            if len(large_df.columns) >= METRIC_NUM:
                break
        data_df = large_df.iloc[:, :METRIC_NUM]

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
    metrics_dimension = util.count_metrics(metrics_dimension, data_df, 0)
    metrics_dimension["total"] = [len(data_df.columns)]

    # Reduce metrics
    ## Step 1: Reduced metrics by CV
    reduced_by_cv_df = pd.DataFrame()
    start = time.time()
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

    time_cv = round(time.time() - start, 2)
    metrics_dimension = util.count_metrics(metrics_dimension, reduced_by_cv_df, 1)
    metrics_dimension["total"].append(len(reduced_by_cv_df.columns))

    ## Step 2: Reduced by k-Shape
    clustering_info = {}
    reduced_df = reduced_by_cv_df
    start = time.time()

    with futures.ProcessPoolExecutor(max_workers=max_workers) as executor:
        # Clustering metrics by services including services, containers and middlewares
        for ser in services_list:
            target_df = reduced_by_cv_df.loc[:, reduced_by_cv_df.columns.str.startswith(
                ("s-{}_".format(ser), "c-{}_".format(ser), "c-{}-".format(ser), "m-{}_".format(ser), "m-{}-".format(ser)))]
            if len(target_df.columns) in [0, 1]:
                continue
            c_info, remove_list = kshape_clustering(target_df, ser, executor)
            clustering_info.update(c_info)
            reduced_df = reduced_df.drop(remove_list, axis=1)

    time_clustering = round(time.time() - start, 2)
    metrics_dimension = util.count_metrics(metrics_dimension, reduced_df, 2)
    metrics_dimension["total"].append(len(reduced_df.columns))
    #pprint(metrics_dimension)

    # Output summary of results as JSON file
    summary = {}
    summary["data_file"] = DATA_FILE.split("/")[-1]
    summary["number_of_plots"] = PLOTS_NUM
    summary["execution_time"] = {"CV": time_cv, "clustering": time_clustering, "total": round(time_cv+time_clustering, 2)}
    summary["metrics_dimension"] = metrics_dimension
    summary["reduced_metrics"] = list(reduced_df.columns)
    summary["clustering_info"] = clustering_info
    file_name = "sieve_{}.json".format(datetime.now().strftime("%Y%m%d%H%M%S"))
    result_dir = "./results/{}".format(DATA_FILE.split("/")[-1])
    if not os.path.isdir(result_dir):
        os.makedirs(result_dir)
    with open(os.path.join(result_dir, file_name), "w") as f:
        json.dump(summary, f, indent=4)
    # print stdout, too.
    json.dump(summary, sys.stdout, indent=4)
