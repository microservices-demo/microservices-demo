import numpy as np

def z_normalization(data):
    arr = []
    for d in data:
        mean = d.mean()
        std = d.std()
        arr.append((d - mean) / std)
    return np.array(arr)

def count_metrics(metrics_dimension, dataframe, n):
    for col in dataframe.columns:
        if col.startswith("c-"):
            container_name = col.split("_")[0].replace("c-", "")
            if container_name not in metrics_dimension["containers"]:
                metrics_dimension["containers"][container_name] = [0, 0, 0]
            metrics_dimension["containers"][container_name][n] += 1
        elif col.startswith("m-"):
            middleware_name = col.split("_")[0].replace("m-", "")
            if middleware_name not in metrics_dimension["middlewares"]:
                metrics_dimension["middlewares"][middleware_name] = [0, 0, 0]
            metrics_dimension["middlewares"][middleware_name][n] += 1
        elif col.startswith("s-"):
            service_name = col.split("_")[0].replace("s-", "")
            if service_name not in metrics_dimension["services"]:
                metrics_dimension["services"][service_name] = [0, 0, 0]
            metrics_dimension["services"][service_name][n] += 1
        elif col.startswith("n-"):
            node_name = col.split("_")[0].replace("n-", "")
            if node_name not in metrics_dimension["nodes"]:
                metrics_dimension["nodes"][node_name] = [0, 0, 0]
            metrics_dimension["nodes"][node_name][n] += 1
    return metrics_dimension
