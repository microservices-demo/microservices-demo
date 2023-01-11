import time
import logging
import random
import json
from locust import HttpUser, task, between

#usrname: locust
#pwf: locust
#creds encoded to base64 with colon sepator to comply with login function: Basic bG9jdXN0OmxvY3VzdA==
#Basic bG9jdXN0OmxvY3VzdA==

class EvenLoad(HttpUser):
    wait_time = between(0.5,1.5)

    @task
    def even_load(self):
        self.client.get("/index.html")
        self.client.get("/category.html")
        self.client.get("/category.html?tags=" + random.choice(filterList))
        self.client.get("/detail.html?id=" + random.choice(productList))
        for i in range(random.choice([1,2,3,4,5,6,7,8,9])):
            self.client.post("/cart", json={"id": random.choice(productList)})
        self.client.get("/basket.html")
        self.client.post("/orders")
        self.client.get("/customer-orders.html")
        self.client.get("/index.html")

    def on_start(self):
        self.client.get("/login", headers={"Authorization":"Basic bG9jdXN0OmxvY3VzdA=="})
    
    # def add_to_cart(self, id):
    #     self.client.post("/cart", {"id": id})

filterList = [
    "brown","geek","formal","blue","skin","red","action","sport","black","magic","green"
]

productList = [
    "03fef6ac-1896-4ce8-bd69-b798f85c6e0b",
    "3395a43e-2d88-40de-b95f-e00e1502085b",
    "510a0d7e-8e83-4193-b483-e27e09ddc34d",
    "808a2de1-1aaa-4c25-a9b9-6612e8f29a38",
    "819e1fbf-8b7e-4f6d-811f-693534916a8b",
    "837ab141-399e-4c1f-9abc-bace40296bac",
    "a0a4f044-b040-410d-8ead-4de0446aec7e",
    "d3588630-ad8e-49df-bbd7-3167f7efb246",
    "zzz4f044-b040-410d-8ead-4de0446aec7e"
    
]
