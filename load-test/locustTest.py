# Not Used - remove this file.

from locust import HttpLocust, TaskSet, task
from random import randint
import base64


class AnonTasks(TaskSet):

	@task
	def loadImage(self):
		catalogue = self.client.get("/catalogue?size=100")
		sizeResponse = self.client.get("/catalogue/size")
		size = sizeResponse.json()["size"]
		index = randint(0, size-1)
		image = self.client.get(catalogue.json()[index]["imageUrl"])
		print image

class APITasks(TaskSet):
	def on_start(self):
		self.login()

	def login(self):
		base64string = base64.encodestring('%s:%s' % ("Eve_Berger", "duis")).replace('\n', '')
		login = self.client.get("/login", headers={"Authorization":"Basic %s" % base64string})
		# print login.cookies
		self.cust_id = login.cookies["logged_in"]

	@task
	def buy(self):
		catalogue = self.client.get("/catalogue?size=100")
		sizeResponse = self.client.get("/catalogue/size")
		size = sizeResponse.json()["size"]
		index = randint(0, size-1)
		print index
		catItem = catalogue.json()[index]
		print catItem
		self.client.post("/cart", json={"itemId": catItem["Id"], "quantity": 3})
		self.client.post("/orders", json={"customer": self.cust_id})

class LoggedInUser(HttpLocust):
    task_set = APITasks
    min_wait = 5000
    max_wait = 15000

class UnknownUser(HttpLocust):
	task_set = AnonTasks
	min_wait = 5000
	max_wait = 15000