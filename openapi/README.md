# Testing API endpoints with Dredd

This directory contains:
 - Data fixtures for microservices-demo services
 - Testing framework (Dredd) hooks.js file which adds fixtures
 - OpenAPI (Swagger 2.0) specification for each services
 - generate-server.sh generates Go server based on the specs

# Prerequisites
  - ECMA2015 compatible runtime (NodeJS >= v6.x.x)

# How to run

In this directiory run 
```
npm install
```
to install the dependencies

Then:
```
dredd <spec-file-location> <api-endpoint-url> -f hooks.js
```

Success output:
```
info: Beginning Dredd testing...
info: Found Hookfiles: hooks.js
MongoEndpoint: mongodb://localhost:32771/data
pass: GET /carts/1 duration: 141ms
pass: DELETE /carts/1 duration: 32ms
pass: POST /carts/579f21ae98684924944651bf/items duration: 133ms
skip: PATCH /carts/579f21ae98684924944651bf/items
pass: DELETE /carts/579f21ae98684924944651bf/items/819e1fbf-8b7e-4f6d-811f-693534916a8b duration: 31ms
complete: 4 passing, 0 failing, 0 errors, 1 skipped, 5 total
complete: Tests took 792ms
```


# Run with docker
Start microservices demo app with docker compose:
```
cd /path/to/microservices-demo/deploy/docker-only/
docker-compose up -d
```

Build included docker image with:
```
docker build -t "weaveworksdemos/openapi:latest" .
```

Run the openapi testing container:
```
docker run --rm --net dockeronly_default --link dockeronly_accounts-db_1 --link dockeronly_accounts_1 --env MONGO_ENDPOINT=mongodb://accounts-db:27017/data weaveworksdemos/openapi /tmp/specs/accounts/accounts.json http://accounts -f /tmp/specs/accounts/hooks.js
```

# Docker-compose
Look at ```docker-compose.yml``` for reference.

```
JSON_SPEC=accounts/accounts.json API_ENDPOINT=http://localhost:8080 docker-compose up --abort-on-container-exit

```
