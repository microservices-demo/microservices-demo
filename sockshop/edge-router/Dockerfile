FROM nginx:1.11.0-alpine
WORKDIR /
COPY start-nginx.sh /start-nginx.sh
COPY nginx.conf.template /nginx.conf.template

CMD ["/start-nginx.sh"]
