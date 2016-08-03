FROM golang:1.6-wheezy

RUN go get github.com/streadway/amqp

COPY *.go /go/src/github.com/containersolutions/weave-demo/worker/
RUN go install github.com/containersolutions/weave-demo/worker/

ENTRYPOINT ["/go/bin/worker", "-port=80"]