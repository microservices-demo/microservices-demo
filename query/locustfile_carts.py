import time
import logging
import random
from locust import HttpUser, task, between

class Cartsload(HttpUser):
    wait_time = between(0.5,1.5)

    @task
    def cart_load(self):
        self.client.get("/basket.html")

    def on_start(self):
        self.client.get("/index.html", headers={"Authorization":"BasicAGwAbwBjAHUAcwB0:AGwAbwBjAHUAcwB0"})

productList = [    
]
filterList = [
    "brown","geek","formal","blue","skin","red","action","sport","black","magic","green"
]
