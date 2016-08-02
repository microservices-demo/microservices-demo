# Testing API endpoints with Dredd

This directory contains:
 - Data fixtures for microservices-demo services
 - Testing framework (Dredd) hooks.js file which adds fixtures
 - OpenAPI (Swagger 2.0) specification for each services

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
dredd --config <service_dir>/dredd.yml
```
