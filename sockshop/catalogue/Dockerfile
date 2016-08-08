FROM golang:1.6

COPY socks.json /config/socks.json
RUN mkdir /app
COPY . /go/src/github.com/microservices-demo/microservices-demo/sockshop/catalogue/
COPY images/ /app/images/

RUN go get github.com/gorilla/mux github.com/go-kit/kit/log github.com/go-kit/kit/endpoint github.com/go-kit/kit/transport/http

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/main github.com/microservices-demo/microservices-demo/sockshop/catalogue/cmd/cataloguesvc

CMD ["/app/main", "-port=80"]

EXPOSE 80