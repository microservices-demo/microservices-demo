.PHONY: all_tests docker_container 
all_tests: docker_container example

docker_container:
	docker build -t microservice-demo-docdoctor .

example:
	docker run --rm -ti -v $(shell pwd)/../example:/to-test microservice-demo-docdoctor
