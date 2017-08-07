import itertools
import operator
import os

from grafanalib.core import *

def service_row(datasource, serviceTitle, serviceName):
    return Row(
        title=serviceTitle,
        showTitle=True,
        panels=[
            service_qps_graph(datasource, serviceTitle, serviceName),
            service_latency_graph(datasource, serviceTitle, serviceName),
        ],
    )

def service_qps_graph(datasource, serviceTitle, serviceName):
    title = serviceTitle + " QPS"
    return Graph(
        title=title,
        dataSource=datasource,
        span=6,
        lineWidth=1,
        legend=Legend(
            show=True,
            alignAsTable=True,
        ),
        targets=[
            Target(
                expr='sum(rate(request_duration_seconds_count{name="%s",status_code=~"2..",route!="metrics"}[1m])) * 100' % (serviceName),
                legendFormat="2xx",
                refId='A',
            ),
            Target(
                expr='sum(rate(request_duration_seconds_count{name="%s",status_code=~"4.+|5.+"}[1m])) * 100' % (serviceName),
                legendFormat="4xx/5xx",
                refId='B',
            ),
        ],
        xAxis=XAxis(mode="time"),
        yAxes=[
            YAxis(format=OPS_FORMAT, show=True, label="QPS (1 min)", min=0),
            YAxis(format=SHORT_FORMAT, show=True, min=None),
        ],
    )

def service_latency_graph(datasource, serviceTitle, serviceName):
    title = serviceTitle + " Latency"
    return Graph(
        title=title,
        dataSource=datasource,
        span=6,
        lineWidth=1,
        targets=[
            Target(
                expr='histogram_quantile(0.99, sum(rate(request_duration_seconds_bucket{name="%s"}[1m])) by (name, le))' % (serviceName),
                legendFormat="99th quantile",
                refId='A',
            ),
            Target(
                expr='histogram_quantile(0.5, sum(rate(request_duration_seconds_bucket{name="%s"}[1m])) by (name, le))' % (serviceName),
                legendFormat="50th quantile",
                refId='B',
            ),
            Target(
                expr='sum(rate(request_duration_seconds_sum{name="%s"}[1m])) / sum(rate(request_duration_seconds_count{name="%s"}[1m]))' % (serviceName, serviceName),
                legendFormat="mean",
                refId='C',
            ),
        ],
        xAxis=XAxis(mode="time"),
        yAxes=[
            YAxis(format=SECONDS_FORMAT, show=True, min=0),
            YAxis(format=SHORT_FORMAT, show=True, min=None),
        ],
    )

datasource = "prometheus"
rows = []
services = [
        {"name": "catalogue", "title": "Catalogue"},
        {"name": "carts", "title": "Cart"},
        {"name": "orders", "title": "Orders"},
        {"name": "payment", "title": "Payment"},
        {"name": "shipping", "title": "Shipping"},
        {"name": "user", "title": "User"},
        {"name": "front-end", "title": "Front End"},
]

for service in services:
    rows.append(service_row(datasource, service["title"], service["name"]))

dashboard = Dashboard(
    title="Sock Shop Performance",
    time=Time("now-30m", "now"),
    timezone="browser",
    refresh="5s",
    rows=rows,
).auto_panel_ids()
