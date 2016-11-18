FROM alpine:3.4

ENV TERM=xterm
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk update && apk add --no-cache ruby-json curl docker py-pip jq openssh
RUN curl https://releases.hashicorp.com/packer/0.12.0/packer_0.12.0_linux_amd64.zip -o packer.zip && \
    unzip packer.zip && \
    mv packer /usr/bin/ 
RUN curl https://releases.hashicorp.com/terraform/0.7.11/terraform_0.7.11_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/bin/
RUN pip install docker-compose awscli
