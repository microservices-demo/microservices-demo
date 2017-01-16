FROM alpine:3.5

RUN apk update && \
    apk add ruby ruby-json ruby-rdoc ruby-irb

RUN gem install awesome_print

COPY healthcheck.rb healthcheck.rb
ENTRYPOINT ["ruby", "healthcheck.rb"]
