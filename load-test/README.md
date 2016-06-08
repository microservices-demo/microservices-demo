# Load / Integration Tests

# Running locally

## Requirements 
* locust `pip install locustio`

`./runLocust.sh -h [host] -c [number of clients] -r [number of requests]`
Clients and Requests arguments are optional and default to 2 and 10.

# Running in Docker Container
* Build `docker build -t load-tset .`
* Run `docker run -e "TARGET_HOST=[HOST]" load-test`
