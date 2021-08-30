.PHONY: gen-complete-demo
gen-complete-demo:
	make -C deploy/kubernetes docker-gen-complete-demo

.PHONY: check-generated-files
check-generated-files:
	make -C deploy/kubernetes docker-check-complete-demo

build-frontend-and-run:
	#docker build -t front-end ../front-end
	GROUP=weaveworksdemos COMMIT=test ../orders/scripts/build_local.sh 
	docker-compose -f deploy/docker-compose/docker-compose.yml up -d