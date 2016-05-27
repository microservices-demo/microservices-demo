FROM golang:1.6

EXPOSE 80
COPY socks.json /config/socks.json
RUN go get github.com/gorilla/mux

COPY *.go /go/src/github.com/containersolutions/weave-demo/catalogueService/
RUN go install github.com/containersolutions/weave-demo/catalogueService/

ENTRYPOINT ["/go/bin/catalogueService", "-port=80"]