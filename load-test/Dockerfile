FROM python:2.7-wheezy

COPY . /load_tester/

# Install locust
RUN pip install locustio

EXPOSE 80

WORKDIR = /load_tester

ENTRYPOINT ["./runLocust.sh"]