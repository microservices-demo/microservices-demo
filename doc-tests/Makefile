.PHONY: all_tests docker_container check-ecs2-env
help:
	cat Makefile

test_all: docker_only test_ecs

docker_container:
	docker build -t microservice-demo-docdoctor .

test_docker_compose: docker_container
	docker run --rm -ti \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd)/../deploy/docker-compose:/docker-compose \
		-v $(shell pwd)/../docs/deployment/docker-compose.md:/docker-compose/README.md \
                -w /docker-compose \
		microservice-demo-docdoctor

test_docker_compose_weave: docker_container
	docker run --rm -ti \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd)/../deploy/docker-compose-weave:/docker-compose-weave \
		-v $(shell pwd)/../docs/deployment/docker-compose-weave.md:/docker-compose-weave/README.md \
		-w /docker-compose-weave \
		microservice-demo-docdoctor

test_ecs: check-ec2-env
	docker run --rm -ti \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd)/../deploy/aws-ecs:/to-test \
		-v $(shell pwd)/../docs/deployment/ecs.md:/to-test/README.md \
		-e AWS_ACCESS_KEY_ID="$$AWS_ACCESS_KEY_ID" \
		-e AWS_SECRET_ACCESS_KEY="$$AWS_SECRET_ACCESS_KEY" \
		-e AWS_DEFAULT_REGION="$$AWS_DEFAULT_REGION" \
		microservice-demo-docdoctor

check-ec2-env:
	@if [ "x$$AWS_ACCESS_KEY_ID" = "x" ]; then echo "AWS_ACCESS_KEY_ID not set!"; exit 1; fi
	@if [ "x$$AWS_SECRET_ACCESS_KEY" = "x" ]; then echo "AWS_SECRET_ACCESS_KEY not set!"; exit 1; fi
	@if [ "x$$AWS_DEFAULT_REGION" = "x" ]; then echo "AWS_DEFAULT_REGION not set!"; exit 1; fi
