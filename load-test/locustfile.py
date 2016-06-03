from locust import HttpLocust, TaskSet, task
from random import randint
import base64
import time


class AnonTasks(TaskSet):

	@task
	def loadImage(self):
		print self
		catalogue = self.client.get("/catalogue?size=100")
		sizeResponse = self.client.get("/catalogue/size")
		size = sizeResponse.json()["size"]
		index = randint(0, size-1)
		image = self.client.get(catalogue.json()[index]["imageUrl"])
		print image

	@task
	def getTags(self):
		tags = self.client.get("/tags")
		body = tags.json()
		print body

class APITasks(TaskSet):
	def on_start(self):
		self.login()

	def login(self):
		base64string = base64.encodestring('%s:%s' % ("Eve_Berger", "duis")).replace('\n', '')
		login = self.client.get("/login", headers={"Authorization":"Basic %s" % base64string})
		print login.cookies
		self.cust_id = login.cookies["logged_in"]

	# @task
	# def getCart(self):
	# 	cart = self.client.get("/cart")
	# 	print cart
		# catalogue = self.client.get("/catalogue?size=100")
		# sizeResponse = self.client.get("/catalogue/size")
		# size = sizeResponse.json()["size"]
		# index = randint(0, size-1)
		# print index
		# catItem = catalogue.json()[index]
		# print catItem
		# self.client.post("/cart", json={"itemId": catItem["Id"], "quantity": 3})
		# self.client.post("/orders", json={"customer": self.cust_id})

	@task
	def buy(self):
		cart = self.client.get("/cart")
		catalogue = self.client.get("/catalogue?size=100")
		sizeResponse = self.client.get("/catalogue/size")
		size = sizeResponse.json()["size"]
		index = randint(0, size-1)
		print index
		catItem = catalogue.json()[index]
		print catItem
		time.sleep(5)
		self.client.post("/cart", json={"id": catItem["Id"], "quantity": 3})
		self.client.post("/orders", json={"customer": self.cust_id})

class ErrorTasks(TaskSet):

	@task
	def login_fail(self):
		base64string = base64.encodestring('%s:%s' % ("wrong_user", "no_pass")).replace('\n', '')
		with self.client.get("/login", headers={"Authorization":"Basic %s" % base64string}, catch_response=True) as response:
			if response.status_code == 401:
				response.success()

	@task
	def cart_fail(self):
		with self.client.get("/cart", catch_response=True) as response:
			if response.status_code == 401:
				response.success()

class LoggedInUser(HttpLocust):
	task_set = APITasks
	min_wait = 5000
	max_wait = 10000

class UnknownUser(HttpLocust):
	task_set = AnonTasks
	min_wait = 5000
	max_wait = 10000

class ErrorUser(HttpLocust):
	task_set = ErrorTasks
	min_wait = 5000
	max_wait = 10000