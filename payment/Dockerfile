FROM golang:1.6-alpine

COPY *.* /go/src/github.com/containersolutions/weave-demo/payment/
RUN go install github.com/containersolutions/weave-demo/payment/

#EXPOSE 80

ENTRYPOINT ["/go/bin/payment", "-port=80"]