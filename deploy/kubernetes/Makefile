MANIFESTS = $(or $(shell printenv MANIFESTS), manifests)

.PHONY: gen-complete-demo
gen-complete-demo:
	cat ${MANIFESTS}/* > complete-demo.yaml

.PHONY: val-complete-demo
val-complete-demo:
	cat ${MANIFESTS}/* | diff complete-demo.yaml -
