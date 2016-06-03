# Load / Integration Tests

# Running locally

## Requirements 
* locust `pip install locustio`

`./runLocust.sh [host]`

# Running in Docker Container
* Build `docker build -t load-tset .`
* Run `docker run -e "TARGET_HOST=[HOST]" load-test`


## The script currently starts 2 users, and runs 10 requests before exiting. These values can be changed in the `runLocust.sh` script for now.