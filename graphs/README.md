# Grafana Dashboards
We have included a set of dashboards for Grafana in this demo application.
Most of the source of these dashboards look exactly the same. For the sake of
keeping our code DRY, we have decided to generate our dashboards using [grafanalib](https://github.com/weaveworks/grafanalib).

# Requirements
If you don't have Python installed on your computer but do have Docker, then Docker and Make will
make your life easier today:

| what   | version   |
| ------ | --------- |
| make   | `>= 4.1`  |
| docker | `>= 17`   |

# Getting Started

## The Base Image
All the tooling required to generate the dashboards is inside a container. Build it with like this:

```
docker build -t weaveworks/grafanalib .
```

## Generating Dashboards
Make sure that you run the following commands from within the `graphs/` directory:

```
cd graphs/
docker run --rm -it -v ${PWD}:/opt/code weaveworks/grafanalib /bin/sh -c 'ls /opt/code/*.dashboard.py | parallel generate-dashboard -o {.}.json {}'
```

This will output all the dashboards for Grafana in JSON format, ready to be imported.

```
ls -l *.json
-rw-r--r-- 1 john admin 31361 Aug 30 16:12 kubernetes.dashboard.json
-rw-r--r-- 1 john admin 16729 Aug 30 16:12 prometheus.dashboard.json
-rw-r--r-- 1 john admin 40797 Aug 30 16:12 sock-shop-performance.dashboard.json
-rw-r--r-- 1 john admin 17859 Aug 30 16:12 sock-shop-resources.dashboard.json
```
