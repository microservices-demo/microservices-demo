import itertools
import operator
import os

from grafanalib.core import *

def qps_graph(title, job_name, label):
    return Graph(
            title="{} QPS".format(title),
            dataSource='prometheus',
            targets=[
                Target(
                    expr="sum(rate(request_duration_seconds_count{%s=\"%s\",status_code=~\"2..\"}[1m])) * 100" % (label, job_name),
                    legendFormat="2xx",
                    refId='A',
                    ),
                Target(
                    expr="sum(rate(request_duration_seconds_count{%s=\"%s\",status_code=~\"4.+|5.+\"}[1m])) * 100" % (label, job_name),
                    legendFormat="4xx/5xx",
                    refId='B',
                    ),
                ],
            yAxes=[
                YAxis(format=OPS_FORMAT),
                YAxis(format=SHORT_FORMAT),
                ],
            )

def latency_graph(title, job_name, label="name"):
    return Graph(
            title="{} latency".format(title),
            dataSource='prometheus',
            targets=[
                Target(
                    expr="histogram_quantile(0.99, sum(rate(request_duration_seconds_bucket{%s=\"%s\"}[1m])) by (name, le))" % (label, job_name),
                    legendFormat="99th quantile",
                    refId='A',
                    ),
                Target(
                    expr="histogram_quantile(0.5, sum(rate(request_duration_seconds_bucket{%s=\"%s\"}[1m])) by (name, le))" % (label, job_name),
                    legendFormat="50th quantile",
                    refId='B',
                    ),
                Target(
                    expr="sum(rate(request_duration_seconds_sum{%s=\"%s\"}[1m])) / sum(rate(request_duration_seconds_count{%s=\"%s\"}[1m]))" % (label, job_name, label, job_name),
                    legendFormat="Mean",
                    refId='C',
                    ),
                ],
            yAxes=[
                YAxis(
                    format=SECONDS_FORMAT,
                    ),
                YAxis(
                    format=SHORT_FORMAT,
                    show=False,
                    )
                ],
            )

def get_rows():
    rows = []
    cats = {
        "front-end": "Frontend",
        "catalogue": "Catalogue",
        "carts":     "Cart",
        "orders":    "Orders",
        "payment":   "Payment",
        "shipping":  "Shipping",
        "user":      "User"
    }

    job_label = os.environ["HOME"]

    if not job_label:
        job_label = "name"

    for key, value in sorted(cats.items(), key=operator.itemgetter(0)):
        row = Row(panels=[
            qps_graph(value, key, job_label),
            latency_graph(value, key, job_label),
            ])
        rows.append(row)
    return rows

dashboard = Dashboard(
    title="Frontend Stats",
    rows=get_rows(),
).auto_panel_ids()
