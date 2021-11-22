#!/usr/bin/env bash
certs=/etc/docker/certs.d/192.168.1.10:8443
sudo mkdir /registry-image
sudo mkdir /etc/docker/certs
sudo mkdir -p $certs
sudo openssl req -x509 -config ./tls.csr -nodes -newkey rsa:4096 \
-keyout tls.key -out tls.crt -days 365 -extensions v3_req

sudo cp tls.crt $certs
sudo mv tls.* /etc/docker/certs

docker run -d \
  --restart=always \
  --name registry \
  -v /etc/docker/certs:/docker-in-certs:ro \
  -v /registry-image:/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/docker-in-certs/tls.crt \
  -e REGISTRY_HTTP_TLS_KEY=/docker-in-certs/tls.key \
  -p 8443:443 \
  registry:2
