#!/usr/bin/env sh

# Import data sources
for file in *-datasource.json; do
  if [ -e "$file" ]; then
    echo "importing $file" &&
    curl --silent --fail --show-error \
      --request POST http://admin:foobar@grafana:3000/api/datasources \
      --header "Content-Type: application/json" \
      --data-binary "@$file";
    echo "";
  fi
done;

# Import dashboards
for file in *-dashboard.json; do
  if [ -e "$file" ]; then
    echo "importing $file" &&
    cat "$file" \
    | xargs -0 printf '{"dashboard":%s,"overwrite":true,"inputs":[{"name":"DS_PROMETHEUS","type":"datasource","pluginId":"prometheus","value":"prometheus"}]}' \
    | jq -c '.' \
    | curl --silent --fail --show-error \
      --request POST http://admin:foobar@grafana:3000/api/dashboards/import \
      --header "Content-Type: application/json" \
      --data-binary "@-";
    echo "";
  fi
done;
