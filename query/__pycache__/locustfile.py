import time
import logging
from locust import HttpUser, task, between

#creds encoded to base64: AGwAbwBjAHUAcwB0

class QuickstartUser(HttpUser):
    wait_time = between(1, 5)

    @task(3)
    def view_items(self):
        for item_id in range(10):
            returned = self.client.get("/category.html")
            time.sleep(1)

#     def on_start(self):
#         print("starting, print")
#         logging.info('starting, log')
#         self.client.get("/index.html", headers={"Authorization":"BasicAGwAbwBjAHUAcwB0:AGwAbwBjAHUAcwB0"})
#         print("got req, print")
#         logging.info('got req, log')
#    problem with this locust is that the system behves nromally to request, so each 
#    request to a certain part of the system will relatviely evenly also stress othert parts of thew system or will they?
    