FROM golang:1.6

COPY users.json /config/users.json
RUN mkdir /app
COPY . /go/src/github.com/weaveworks/weaveDemo/login/

RUN go get github.com/gorilla/mux github.com/go-kit/kit/log github.com/go-kit/kit/endpoint github.com/go-kit/kit/transport/http

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/main github.com/weaveworks/weaveDemo/login/cmd/loginsvc

CMD ["/app/main", "-port=80"]

EXPOSE 80