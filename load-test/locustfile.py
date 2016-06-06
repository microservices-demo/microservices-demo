from locust import HttpLocust, TaskSet, task
from random import randint
import base64
import time
               	
counter = 0

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

	@task
	def purchaseItem(self):
		createCustomer()
		login()
		addItemToCart()
		buy()
		deleteCustomer

	@task
	def addRemoveFromCart(self):
		createCustomer()
		login()
		addItemToCart()
		removeItemFromCart()
		deleteCustomer()

	def removeItemFromCart(self):
		self.client.delete("/cart/" + self.cart_id + "/items/" + self.item_id)

	# @task
	def addItemToCart(self):
		cart = self.client.get("/cart")
		self.cart_id = cart.json()["id"]
		catalogue = self.client.get("/catalogue?size=100")
		sizeResponse = self.client.get("/catalogue/size")
		size = sizeResponse.json()["size"]
		index = randint(0, size-1)
		print index
		catItem = catalogue.json()[index]
		print catItem
		time.sleep(2.0)
		self.item_id = catItem["Id"]
		self.client.post("/cart", json={"id": self.item_id, "quantity": 3})

	def buy(self):
		self.client.post("/orders", json={"customer": self.cust_id})

	def login(self):
		base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
		login = self.client.get("/login", headers={"Authorization":"Basic %s" % base64string})
		# print login.cookies
		# self.cust_id = login.cookies["logged_in"]

	def createCustomer(self):
		# TODO just use same address/card for all generated customers?
		# address = self.client.post("/accounts/adresses", json={...})
		# card = self.client.post("/accounts/cards", json={...})
		global counter += 1
		self.username = "test_user_" + counter
		self.password = "test_password"
		customer = self.client.post("/accounts/customers", json={"firstName": "testUser_" + counter, "lastName": "Last_Name", "username": self.username, "addresses": ["http://accounts/addresses/0"], "cards": ["http://accounts/cards/0"]})
		self.cust_id = customer.json()["id"]
		self.client.get("/register?username=" + "test_user_" + counter + "&password=" + self.password)

	def deleteCustomer(self):
		self.client.delete("/accounts/customers/" + self.cust_id)

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