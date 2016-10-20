.PHONY: all_tests docker_container check-ecs2-env
help:
	cat Makefile

test_all: docker_only test_ecs test_mesos_cni

docker_container:
	docker build -t microservice-demo-docdoctor .

test_example: docker_container
	docker run --rm -ti -v $(shell pwd)/../example:/to-test microservice-demo-docdoctor

test_docker_only: docker_container
	docker run --rm -ti \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd)/../docker-only:/to-test \
		microservice-demo-docdoctor

test_ecs: check-ec2-env
	docker run --rm -ti \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd)/../aws-ecs:/to-test \
		-e AWS_ACCESS_KEY_ID="$$AWS_ACCESS_KEY_ID" \
		-e AWS_SECRET_ACCESS_KEY="$$AWS_SECRET_ACCESS_KEY" \
		-e AWS_DEFAULT_REGION="$$AWS_DEFAULT_REGION" \
		microservice-demo-docdoctor

test_mesos_cni: check-mesos-cni-env
	docker run --rm -ti \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd)/../mesos-cni:/to-test \
		-e TF_VAR_access_key="$$TF_VAR_access_key" \
		-e TF_VAR_secret_key="$$TF_VAR_secret_key" \
		-e TF_VAR_private_key_file="$$TF_VAR_private_key_file" \
		-e TF_VAR_aws_key_name="$$TF_VAR_aws_key_name" \
		microservice-demo-docdoctor

check-mesos-cni-env:
	@if [ "x$$TF_VAR_access_key" = "x" ]; then echo "TF_VAR_access_key not set!"; exit 1; fi
	@if [ "x$$TF_VAR_secret_key" = "x" ]; then echo "TF_VAR_secret_key not set!"; exit 1; fi
	@if [ "x$$TF_VAR_private_key_file" = "x" ]; then echo "TF_VAR_private_key_file not set!"; exit 1; fi
	@if [ "x$$TF_VAR_aws_key_name" = "x" ]; then echo "TF_VAR_aws_key_name not set!"; exit 1; fi

check-ec2-env:
	@if [ "x$$AWS_ACCESS_KEY_ID" = "x" ]; then echo "AWS_ACCESS_KEY_ID not set!"; exit 1; fi
	@if [ "x$$AWS_SECRET_ACCESS_KEY" = "x" ]; then echo "AWS_SECRET_ACCESS_KEY not set!"; exit 1; fi
	@if [ "x$$AWS_DEFAULT_REGION" = "x" ]; then echo "AWS_DEFAULT_REGION not set!"; exit 1; fi
