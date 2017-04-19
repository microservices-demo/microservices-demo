FROM golang:1.6-wheezy

COPY users.json /config/users.json
RUN go get github.com/gorilla/mux github.com/go-kit/kit/log github.com/go-kit/kit/endpoint github.com/go-kit/kit/transport/http

COPY *.go /go/src/github.com/weaveworks/weaveDemo/login/
COPY cmd/loginsvc/*.go /go/src/github.com/weaveworks/weaveDemo/login/cmd/loginsvc/

RUN go install github.com/weaveworks/weaveDemo/login/cmd/loginsvc

ENTRYPOINT ["/go/bin/loginsvc", "-port=80"]