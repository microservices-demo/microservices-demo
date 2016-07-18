FROM golang:1.6-alpine

RUN apk add --update --no-cache bash \
                                bash-completion \
                                git

RUN go get -v github.com/gorilla/mux github.com/go-kit/kit/...

COPY *.go /go/src/github.com/weaveworks/weaveDemo/payment/
COPY cmd/paymentsvc/*.go /go/src/github.com/weaveworks/weaveDemo/payment/cmd/paymentsvc/

RUN go install github.com/weaveworks/weaveDemo/payment/cmd/paymentsvc

ENTRYPOINT ["/go/bin/paymentsvc", "-port=80"]
