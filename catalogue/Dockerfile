FROM golang:1.6-wheezy

#EXPOSE 80
COPY socks.json /config/socks.json
RUN go get github.com/gorilla/mux

COPY *.go /go/src/github.com/containersolutions/weave-demo/catalogue/
COPY images/ /go/images/

RUN go install github.com/containersolutions/weave-demo/catalogue/

ENTRYPOINT ["/go/bin/catalogue", "-port=80"]