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

def hierarchical_clustering(target_df, dist_func):
    series = target_df.values.T
    norm_series = util.z_normalization(series)
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
    clustering_info, remove_list = {}, []
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
    ## Step 1: Reduced metrics with stationarity
    reduced_by_st_df = pd.DataFrame()
    start = time.time()
    with futures.ProcessPoolExecutor(max_workers=max_workers) as executor:
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

    time_adf = round(time.time() - start, 2)
    metrics_dimension = util.count_metrics(metrics_dimension, reduced_by_st_df, 1)
    metrics_dimension["total"].append(len(reduced_by_st_df.columns))

    ## Step 2: Reduced by hierarchical clustering
    clustering_info = {}
    reduced_df = reduced_by_st_df
    start = time.time()

    with futures.ProcessPoolExecutor(max_workers=max_workers) as executor:
        # Clustering metrics by service including services, containers and middlewares metrics
        future_list = []
        for ser in services_list:
            target_df = reduced_by_st_df.loc[:, reduced_by_st_df.columns.str.startswith(
                ("s-{}_".format(ser), "c-{}_".format(ser), "c-{}-".format(ser), "m-{}_".format(ser), "m-{}-".format(ser)))]
            if len(target_df.columns) in [0, 1]:
                continue
            future_list.append(executor.submit(hierarchical_clustering, target_df, sbd))
        for future in futures.as_completed(future_list):
            c_info, remove_list = future.result()
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
    # print stdout, too.
    json.dump(summary, sys.stdout, indent=4)
