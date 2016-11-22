FROM alpine:3.4

ENV TERM=xterm
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk update && apk add --no-cache ruby-json curl docker py-pip
RUN pip install docker-compose 
