# import time
import logging
import random
from locust import HttpUser, task, between, tag
from datetime import datetime
import base64

#usrname: locust
#pwf: locust
#creds encoded to base64 with colon sepator to comply with login function: Basic bG9jdXN0OmxvY3VzdA==
#Basic bG9jdXN0OmxvY3VzdA==

import string

def get_random_string(length):
    # choose from all lowercase letter
    letters = string.ascii_lowercase
    result_str = ''.join(random.choice(letters) for i in range(length))
    return result_str

class UserTasks(HttpUser):
    wait_time = between(0.5,1.5)

    @tag('even_load')
    @task
    def even_load(self):

        self.client.get("/index.html")
        self.client.get("/category.html")
        self.client.get("/category.html?tags=" + random.choice(filterList))
        self.client.get("/detail.html?id=" + random.choice(productList))
        for _ in range(random.choice([1,2,3,4,5,6,7,8,9])):
            self.client.post("/cart", json={"id": random.choice(productList)})
        self.client.get("/basket.html")
        self.client.get("/orders")
        self.client.get("/customer-orders.html")
        self.client.get("/index.html")

    def on_start(self):
        self.client.get("/login", headers={"Authorization":"Basic bG9jdXN0OmxvY3VzdA=="})
    
    @tag('carts')
    @task
    def carts(self):
        for i in range(random.choice([1,2,3,4,5,6,7,8,9])):
            prod =  random.choice(productList)
            self.client.post("/cart", json={"id": prod})
            self.client.post("/cart/update", json={"id": prod, "quantity": i })
        self.client.get("/basket.html")
        #self.client.delete("/cart")
    
    @tag('users')
    @task
    def user(self):
        randomstring = get_random_string(random.choice([4,5,6,7,8,9]))
        self.client.cookies.clear()
        response = self.client.post("/register", json={"username": randomstring, "password":"qwerty", "email": randomstring } )
        id = response.json()["id"]
        loginres = self.client.get("/login", headers={"Authorization":createcreds(randomstring, "qwerty")})
        if not loginres.ok:
            logging.info("Login failed: " + loginres.text + loginres.reason)
        self.client.post("/addresses", json={"number": "12345678",
        "street": "nowhere st",
        "city": "cornucopia",
        "postcode": "1234",
        "country": "albania"})
        self.client.post("/cards", json={
            "longNum": "123456",
            "expires": "12/24",
            "ccv":"123"
        })
        self.client.delete("/customers/" + id)
    
    @tag('catalog')
    @task
    def catalog(self):
        self.client.get("/category.html?tags=" + random.choice(filterList))
    
    ##NOTE: This endpoint is noted in the docs but is not implemented
    @tag('payment')
    @task
    def payment(self):
        self.client.get("/health")
        self.client.post("/paymentAuth", json={"authorised":"true"})

    @tag('idle')
    @task
    def idle(self):
        return

def createcreds(usr,pwd):
    input = "" + usr + ":" + pwd
    return "Basic " +  base64.b64encode(input.encode("ascii")).decode("ascii")


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