FROM python:2.7-wheezy

# Install locust
RUN pip install locustio

ADD locustfile.py /config/locustfile.py
ADD runLocust.sh /usr/local/bin/runLocust.sh

ENV LOCUST_FILE /config/locustfile.py

EXPOSE 8089

CMD ["/usr/local/bin/runLocust.sh"]