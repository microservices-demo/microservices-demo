FROM golang:1.6-wheezy

COPY socks.json /config/socks.json
RUN go get github.com/gorilla/mux github.com/go-kit/kit/...

COPY *.go /go/src/github.com/weaveworks/weaveDemo/catalogue/
COPY cmd/cataloguesvc/*.go /go/src/github.com/weaveworks/weaveDemo/catalogue/cmd/cataloguesvc/
COPY images/ /go/images/

RUN go install github.com/weaveworks/weaveDemo/catalogue/cmd/cataloguesvc

ENTRYPOINT ["/go/bin/cataloguesvc", "-port=80"]
