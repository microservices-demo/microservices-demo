FROM golang:1.6

COPY *.* /go/src/github.com/containersolutions/weave-demo/paymentService/
RUN go install github.com/containersolutions/weave-demo/paymentService/

EXPOSE 8080

ENTRYPOINT ["/go/bin/paymentService"]