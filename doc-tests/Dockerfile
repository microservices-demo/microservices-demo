FROM ubuntu:xenial

RUN apt-get update && apt-get install -yq ruby
RUN apt-get update && apt-get install -yq apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -yq docker-engine
COPY ./runner/test-documentation /test-documentation
CMD /test-documentation
