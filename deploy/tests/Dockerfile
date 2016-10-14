FROM ubuntu:xenial
VOLUME /to-test
WORKDIR /to-test

RUN apt-get update && apt-get install -yq ruby
COPY ./runner/test-documentation /test-documentation
CMD /test-documentation
