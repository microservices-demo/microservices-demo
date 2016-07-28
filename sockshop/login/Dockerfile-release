FROM busybox:1

WORKDIR /
EXPOSE 80
COPY users.json /config/users.json
COPY app /

CMD ["/app", "-port=80"]
