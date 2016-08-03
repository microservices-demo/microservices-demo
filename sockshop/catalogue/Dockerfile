FROM golang:1.6

RUN mkdir /app
COPY . /go/src/github.com/weaveworks/weaveDemo/catalogue/
COPY images/ /app/images/

RUN go get github.com/gorilla/mux github.com/go-kit/kit/log github.com/go-kit/kit/endpoint github.com/go-kit/kit/transport/http github.com/go-sql-driver/mysql

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/main github.com/weaveworks/weaveDemo/catalogue/cmd/cataloguesvc

CMD ["/app/main", "-port=80"]

EXPOSE 80