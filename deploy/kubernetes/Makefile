PWD = $(shell pwd)
MANIFESTS = $(or $(shell printenv MANIFESTS), manifests)

.PHONY: gen-complete-demo
gen-complete-demo:
	awk '{print}' ${MANIFESTS}/* > complete-demo.yaml
.PHONY: check-complete-demo
check-complete-demo:
	awk '{print}' ${MANIFESTS}/* | diff complete-demo.yaml -
.dockerimage: Dockerfile
	docker build -t manifests-image .
	touch .dockerimage

.PHONY: docker-%
docker-%: .dockerimage
	docker \
	  run \
	  --rm \
	  -it \
	  -u ${UID}:${GID} \
	  -v ${PWD}:/workdir \
	  manifests-image \
	  make $*
