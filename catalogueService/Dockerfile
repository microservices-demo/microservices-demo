FROM golang:1.6

COPY socks.json /config/socks.json

RUN go get github.com/gorilla/mux

COPY *.go /go/src/github.com/containersolutions/weave-demo/catalogueService/
RUN go install github.com/containersolutions/weave-demo/catalogueService/

EXPOSE 8081

ENTRYPOINT ["/go/bin/catalogueService"]