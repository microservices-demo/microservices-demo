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
		print tags
		body = tags.json()
		print body

class APITasks(TaskSet):
	# def on_start(self):
		# self.login()

	@task
	def purchaseItem(self):
		self.createCustomer()
		self.login()
		self.addItemToCart()
		self.buy()
		self.deleteCustomer

	# @task
	# def addRemoveFromCart(self):
	# 	self.createCustomer()
	# 	self.login()
	# 	self.addItemToCart()
	# 	self.removeItemFromCart()
	# 	self.deleteCustomer()

	def removeItemFromCart(self):
		self.client.delete("/cart/" + self.cart_id + "/items/" + self.item_id)

	# @task
	def addItemToCart(self):
		cart = self.client.get("/cart")
		print cart.json()
		# if not cart.json():
			# print 'Cart is empty. Retry in 3 seconds...'
			# print time.time()
			# time.sleep(3.0)
			# print '3 seconds is up'
			# print time.time()
			# cart = self.client.get("/cart")
			# print cart.json()
		# self.cart_id = cart.json()["id"]
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
		print login.cookies
		# self.cust_id = login.cookies["logged_in"]

	def createCustomer(self):
		# TODO just use same address/card for all generated customers?
		address = self.client.post("/addresses", json={"street": "my road", "number": "3", "country": "UK", "city": "London"})
		print '@@@@@ Address '
		print address.json()
		self.address_id = address.json()["_links"]["self"]["href"][27:]
		card = self.client.post("/cards", json={"longNum": "5429804235432", "expires": "04/16", "ccv": "432"})
		print '@@@@@ Card '
		print card.json()
		self.card_id = card.json()["_links"]["self"]["href"][23:]
		global counter
		counter += 1
		self.username = "test_user_" + str(counter)
		self.password = "test_password"
		customer = self.client.post("/customers", json={"firstName": "testUser_" + str(counter), "lastName": "Last_Name", "username": self.username, "addresses": ["http://accounts/addresses/" + self.address_id], "cards": ["http://accounts/cards/" + self.card_id]})
		print '@@@@@ Customer '
		print customer.json()
		self.cust_id = customer.json()["_links"]["self"]["href"][27:]
		self.client.get("/register?username=" + "test_user_" + str(counter) + "&password=" + self.password)

	def deleteCustomer(self):
		self.client.delete("/customers/" + self.cust_id)
		self.client.delete("/addresses/" + self.address_id)
		self.client.delete("/cards/" + self.card_id)

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
			if response.status_code == 500:
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