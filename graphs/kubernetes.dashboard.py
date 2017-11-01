import itertools
import operator
import os

from grafanalib.core import *

datasource = "prometheus"

dashboard = Dashboard(
    title="Kubernetes Pod Resources",
    time=Time("now-3h", "now"),
    timezone="browser",
    rows=[
        Row(
            title="all pods",
            showTitle=True,
            height=Pixels(180),
            panels=[
                SingleStat(
                    title="Memory Working Set",
                    valueName="current",
                    dataSource=datasource,
                    format="percent",
                    thresholds="65,90",
                    span=4,
                    colorValue=True,
                    targets=[
                        Target(
                            expr='sum (container_memory_working_set_bytes{id="/"}) / sum (machine_memory_bytes) * 100',
                            refId="A",
                        ),
                    ],
                    gauge=Gauge(
                        minValue=0,
                        maxValue=100,
                        thresholdMarkers=True,
                        show=True,
                    ),
                ),
                SingleStat(
                    title="CPU Usage",
                    valueName="current",
                    dataSource=datasource,
                    format="percent",
                    thresholds="65,90",
                    decimals=2,
                    span=4,
                    colorValue=True,
                    targets=[
                        Target(
                            expr='sum(rate(container_cpu_usage_seconds_total{id="/",}[1m])) / sum (machine_cpu_cores) * 100',
                            step="10s",
                            refId="A",
                        ),
                    ],
                    gauge=Gauge(
                        minValue=0,
                        maxValue=100,
                        thresholdMarkers=True,
                        show=True,
                    ),
                ),
                SingleStat(
                    title="Filesystem Usage",
                    valueName="current",
                    dataSource=datasource,
                    format="percent",
                    thresholds="65,90",
                    decimals=2,
                    span=4,
                    colorValue=True,
                    targets=[
                        Target(
                            expr='sum(container_fs_usage_bytes{id="/"}) / sum(container_fs_limit_bytes{id="/"}) * 100',
                            step="10s",
                            refId="A",
                        ),
                    ],
                    gauge=Gauge(
                        minValue=0,
                        maxValue=100,
                        thresholdMarkers=True,
                        show=True,
                    ),
                ),
                SingleStat(
                    title="Used",
                    valueName="current",
                    valueFontSize="50%",
                    height=Pixels(1),
                    format="bytes",
                    decimals=2,
                    dataSource=datasource,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(container_memory_working_set_bytes{id="/"})',
                            refId="A",
                        ),
                    ],
                ),
                SingleStat(
                    title="Total",
                    valueName="current",
                    valueFontSize="50%",
                    height=Pixels(1),
                    format="bytes",
                    decimals=2,
                    dataSource=datasource,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(machine_memory_bytes)',
                            refId="A",
                        ),
                    ],
                ),
                SingleStat(
                    title="Used",
                    valueName="current",
                    valueFontSize="50%",
                    height=Pixels(1),
                    format=NO_FORMAT,
                    decimals=2,
                    dataSource=datasource,
                    span=2,
                    postfix=" cores",
                    targets=[
                        Target(
                            expr='sum(rate(container_cpu_usage_seconds_total{id="/"}[1m]))',
                            refId="A",
                        ),
                    ],
                ),
                SingleStat(
                    title="Total",
                    valueName="current",
                    valueFontSize="50%",
                    height=Pixels(1),
                    format=NO_FORMAT,
                    decimals=2,
                    dataSource=datasource,
                    span=2,
                    postfix=" cores",
                    targets=[
                        Target(
                            expr='sum(machine_cpu_cores)',
                            refId="A",
                        ),
                    ],
                ),
                SingleStat(
                    title="Used",
                    valueName="current",
                    valueFontSize="50%",
                    height=Pixels(1),
                    format=BYTES_FORMAT,
                    decimals=2,
                    dataSource=datasource,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(container_fs_usage_bytes{id="/"})',
                            refId="A",
                        ),
                    ],
                ),
                SingleStat(
                    title="Total",
                    valueName="current",
                    valueFontSize="50%",
                    height=Pixels(1),
                    format=BYTES_FORMAT,
                    decimals=2,
                    dataSource=datasource,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(container_fs_limit_bytes{id="/"})',
                            refId="A",
                        ),
                    ],
                ),
                Graph(
                    title="Network",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        sideWidth=Pixels(200),
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(rate(container_network_receive_bytes_total[1m]))',
                            legendFormat="receive",
                            refId='A',
                        ),
                        Target(
                            expr='- sum(rate(container_network_transmit_bytes_total[1m]))',
                            legendFormat="transmit",
                            refId='B',
                        ),
                    ],
                    yAxes=[
                        YAxis(format="Bps", show=True, label="transmit / receive", min=None),
                        YAxis(format="Bps", show=False),
                    ],
                ),
            ]
        ),
        Row(
            title="each pod",
            showTitle=True,
            height=Pixels(250),
            panels=[
                Graph(
                    title="CPU Usage",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        sideWidth=Pixels(200),
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(rate(container_cpu_usage_seconds_total{image!="",name=~"^k8s_.*"}[1m])) by (pod_name)',
                            legendFormat="{{ pod_name }}",
                            refId='A',
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format=NO_FORMAT, show=True, label="cores", min=None),
                        YAxis(format=NO_FORMAT, show=True, label="cores", min=None),
                    ],
                ),
                Graph(
                    title="Memory Working Set",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        sideWidth=Pixels(200),
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(container_memory_working_set_bytes{image!="",name=~"^k8s_.*"}) by (pod_name)',
                            legendFormat="{{ pod_name }}",
                            refId='A',
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format=BYTES_FORMAT, show=True, label="used", min=None),
                        YAxis(format=BYTES_FORMAT, show=True, label="used", min=None),
                    ],
                ),
                Graph(
                    title="Network",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        sideWidth=Pixels(200),
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(rate(container_network_receive_bytes_total{image!="",name=~"^k8s_.*",}[1m])) by (pod_name)',
                            legendFormat="{{ pod_name }} < in",
                            refId='A',
                            metric="network",
                            step="2",
                        ),
                        Target(
                            expr='- sum (rate (container_network_transmit_bytes_total{image!="",name=~"^k8s_.*",}[1m])) by (pod_name)',
                            legendFormat="{{ pod_name }} > out",
                            refId='B',
                            metric="network",
                            step="2",
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format="Bps", show=True, label="transmit / receive", min=None),
                        YAxis(format=SHORT_FORMAT, show=False, min=None),
                    ],
                ),
                Graph(
                    title="Filesystem",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        sideWidth=Pixels(200),
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(container_fs_usage_bytes{image!="",name=~"^k8s_.*"}) by (pod_name)',
                            legendFormat="{{ pod_name }}",
                            refId='A',
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format=BYTES_FORMAT, show=True, label="used", min=None),
                        YAxis(format=SHORT_FORMAT, show=False, min=None),
                    ],
                ),
            ],
        ),
    ],
).auto_panel_ids()
