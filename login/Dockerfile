FROM golang:1.6-alpine

COPY users.json /config/users.json

COPY *.go /go/src/github.com/containersolutions/weave-demo/login/
RUN go install github.com/containersolutions/weave-demo/login/

ENTRYPOINT ["/go/bin/login", "-port=80"]