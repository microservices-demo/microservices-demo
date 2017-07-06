import itertools
import operator
import os

from grafanalib.core import *

datasource = "prometheus"

dashboard = Dashboard(
      title="Prometheus Stats",
      time=Time('now-3h', 'now'),
      timezone="browser",
      rows=[
        Row(panels=[
          SingleStat(
            title="Uptime",
            format='s',
            decimals=1,
            valueName='current',
            dataSource=datasource,
            span=4,
            targets=[
              Target(
                expr='(time() - process_start_time_seconds{job="monitoring/prometheus"})',
                refId='A',
              )
            ],
          ),
          SingleStat(
            title="Local Storage Memory Series",
            valueName='current',
            dataSource=datasource,
            span=4,
            targets=[
              Target(
                expr='prometheus_local_storage_memory_series',
                refId='A',
              )
            ],
            sparkline=SparkLine(
                show=True,
            ),
          ),
          SingleStat(
            title="Internal Storage Queue Length",
            valueName='current',
            dataSource=datasource,
            span=4,
            thresholds="500,4000",
            colorValue=True,
            targets=[
              Target(
                expr='prometheus_local_storage_indexing_queue_length',
                refId='A',
              )
            ],
            sparkline=SparkLine(
                show=True,
            ),
            valueMaps=[
                ValueMap(
                    op="=",
                    text="Empty",
                    value="0"
                ),
            ],
          ),
        ]),
        Row(panels=[
            Graph(
                title="Samples ingested (rate-5m)",
                dataSource=datasource,
                span=12,
                targets=[
                    Target(
                        expr="rate(prometheus_local_storage_ingested_samples_total[5m])",
                        legendFormat="{{ job }}",
                        refId="A",
                    ),
                ],
                yAxes=[
                    YAxis(format=SHORT_FORMAT),
                    YAxis(format=SHORT_FORMAT),
                ],
                xAxis=XAxis(mode="time"),
            ),
        ]),
        Row(panels=[
            Graph(
                title="Target Scrapes (last 5m)",
                dataSource=datasource,
                span=6,
                targets=[
                    Target(
                        expr="rate(prometheus_target_interval_length_seconds_count[5m])",
                        legendFormat="{{ job }}",
                        refId="A",
                    ),
                ],
                yAxes=[
                    YAxis(format=SHORT_FORMAT),
                    YAxis(format=SHORT_FORMAT),
                ],
                xAxis=XAxis(mode="time"),
            ),
            Graph(
                title="Scrape Duration",
                dataSource=datasource,
                span=6,
                targets=[
                    Target(
                        expr='prometheus_target_interval_length_seconds{quantile!="0.01", quantile!="0.05"}',
                        legendFormat="{{ quantile }} ({{ interval }})",
                        refId="A",
                    ),
                ],
                yAxes=[
                    YAxis(format=SHORT_FORMAT, min=None),
                    YAxis(format=SHORT_FORMAT, min=None),
                ],
                xAxis=XAxis(mode="time"),
            ),
        ]),
        Row(panels=[
            Graph(
                title="Rule Eval Duration",
                dataSource=datasource,
                span=12,
                targets=[
                    Target(
                        expr='prometheus_evaluator_duration_milliseconds{quantile!="0.01", quantile!="0.05"}',
                        legendFormat="{{ quantile }}",
                        refId="A",
                    ),
                ],
                yAxes=[
                    YAxis(format=PERCENT_UNIT_FORMAT, min=None),
                    YAxis(format=SHORT_FORMAT, min=None),
                ],
                xAxis=XAxis(mode="time"),
            ),
        ]),
      ],
    ).auto_panel_ids()
