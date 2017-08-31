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
docker run --rm -it -v ${PWD}:/opt/code weaveworks/grafanalib /bin/sh -c 'ls /opt/code/*.dashboard.py | parallel generate-dashboard -o {.}.json {}'
```

## TODO
Generate dashboard for:
- [x] prometheus-stats-dashboard.json
- [ ] k8s-pod-resources-dashboard.json
- [ ] sock-shop-resources-dashboard.json
- [ ] sock-shop-analytics-dashboard.json
