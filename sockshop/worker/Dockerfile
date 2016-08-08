FROM golang:1.6-wheezy

RUN go get github.com/streadway/amqp

COPY *.go /go/src/github.com/microservices-demo/microservices-demo/sockshop/worker/
RUN go install github.com/microservices-demo/microservices-demo/sockshop/worker/

ENTRYPOINT ["/go/bin/worker", "-port=80"]