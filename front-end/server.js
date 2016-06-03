var request = require('request');
var express = require('express');
var path = require("path");
var bodyParser = require("body-parser");
var async = require("async");
var cookieParser = require("cookie-parser");

var app = express();
app.use(express.static(__dirname + "/"));
app.use(bodyParser.json());
app.use(cookieParser());
app.use(function(err, req, res, next) {
	console.error(err.stack);
	res.status(err.status || 500);
	res.render('error', {            
		message: err.message,
        error: err
    });
});

var catalogueUrl = "http://catalogue";
var accountsUrl = "http://accounts/accounts";
var cartsUrl = "http://cart/carts";
var ordersUrl = "http://orders/orders";
var itemsUrl = "http://cart/items";
var customersUrl = "http://accounts/customers";
var loginUrl = "http://login/login";
var tagsUrl = catalogueUrl + "/tags";

console.log(app.get('env'));
if (app.get('env') == "development") {
	catalogueUrl = "http://192.168.99.101:32768";
	accountsUrl = "http://localhost:8082/accounts";
	cartsUrl = "http://192.168.99.103:32769/carts";
	itemsUrl = "http://192.168.99.103:32769/items";
	ordersUrl = "http://localhost:8083/orders";
	customersUrl = "http://localhost:8082/customers";
	loginUrl = "http://192.168.99.101:32769/login";
	tagsUrl = catalogueUrl + "/tags";
}

// TODO Add logging

var cookie_name = 'logged_in';

/**
 * HELPERS
 */
function handleError(error, response) {
	if (error != null || response.statusCode >= 400) {
		if (response != null) {
			console.error("Received error: Response = " + response.statusCode + ", Error = " + error);
		} else {
			console.error("Received error: Error = " + error);
		}
		return true;
	}
	return false;
}

function handleSuccess(res, body) {
	console.log(body);
	res.writeHeader(200);
	res.write(body);
	res.end()
}

function simpleHttpRequest(url, res, next) {
	console.log("GET " + url);
	request.get(url, function (error, response, body) {
		if (handleError(error, response)) {
			return next(error);
		} else {
			handleSuccess(res, body)
		}
	}.bind({res: res}));
}

/**
 * API
 */

// Login
app.get("/login", function (req, res, next) {
	console.log("Received login request");
	var options = {
		headers: {
			'Authorization': req.get('Authorization')
		},
		uri: loginUrl
	};
	request(options, function (error, response, body) {
		if (error) {
			return next(error);
		}
		if (response.statusCode == 200 && body != null && body != "") {
			console.log(body);
			customerId = JSON.parse(body).id;
			console.log(customerId);
			res.status(200);
			res.cookie(cookie_name, customerId, {maxAge: 3600000}).send('Cookie is set');
			console.log("Sent cookies.");
			res.end();
			return
		} else {
			console.log(response.statusCode);
		}
		res.status(401);
		res.end();
	}.bind({res: res}));
});

// Catalogue
app.get("/catalogue/images*", function (req, res, next) {
	var url = catalogueUrl + req.url.toString();
	request.get(url).pipe(res);
});

app.get("/catalogue*", function (req, res, next) {
	simpleHttpRequest(catalogueUrl + req.url.toString(), res, next);
});

app.get("/tags", function(req, res, next) {
	simpleHttpRequest(tagsUrl, res, next);
});

//Carts
// List items in cart for current logged in user.
// TODO: Refactor this into async.waterfall method.
app.get("/cart", function (req, res) {
	console.log("Request received: " + req.url + ", " + req.query.custId);

	// Check if logged in. Get customer Id
	var custId = req.cookies.logged_in;

	// TODO REMOVE THIS, SECURITY RISK
	if (app.get('env') == "development" && req.query.custId != null) {
		custId = req.query.custId;
	}
	// custId = 1; 	// TODO REMOVE!!! TESTING

	if (!custId) {
		console.warn("Cannot fetch cart. User not logged in.")
		res.status(401);
		res.end();
		return
	}
	// If cart doesn't exist yet, create cart for this user
	request.get(cartsUrl + "/search/findByCustomerId?custId=" + custId, function (error, response, body) {
		if (!handleError(error, response)) {
			console.log("Received response: " + JSON.stringify(body));
			jsonBody = JSON.parse(body);
			carts = jsonBody._embedded.carts;
			if (carts.length == 0) {
				console.log("Cart does not exist for: " + custId);
				request.post(
					{
						uri: cartsUrl
						, json: true
						, body: {"customerId": custId}
					}, function (error, response, body) {
						if (response.statusCode == 201) {
							// Get cart url
							cartUrl = body._links.cart.href;
							console.log('New cart created for customerId: ' + custId + ', at: ' + cartUrl);
							getItems(cartUrl, res); // Return cart items
						} else {
							console.log('error: ' + response.statusCode)
							console.log(body)
						}
					}.bind({res: res}))
			} else {
				console.log("Cart already exists for customer id: " + custId);
				// Get cart url
				request.get(cartsUrl + "/search/findByCustomerId?custId=" + custId, function (error, response, body) {
					var cartUrl = "";
					if (!handleError(error, response)) {
						console.log("Received response: " + JSON.stringify(body));
						jsonBody = JSON.parse(body);
						console.log(JSON.stringify(jsonBody._embedded.carts[0]._links));
						cartUrl = jsonBody._embedded.carts[0]._links.cart.href;
						getItems(cartUrl, res); // Return cart items
					}
				}.bind({res: res}))
			}

		}
	}.bind({res: res}));
})

function getItems(cartUrl, res) {
	async.waterfall([
			function (callback) {
				request.get(cartUrl, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("Received response: " + JSON.stringify(body));
					jsonBody = JSON.parse(body);
					link = jsonBody._links.items.href;
					callback(null, link);
				});
			},
			function (arg1, callback) {
				request.get(arg1, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("Received response: " + JSON.stringify(body));
					try {
						callback(null, JSON.parse(body));
					} catch (e) {
						console.log("Cart is empty.");
						callback(null);
						return;
					}
				});
			}
		],
		function (err, result) {
			if (err) {
				return next(err);
			}
			res.writeHeader(200);
			if (result != null) {
				res.end(JSON.stringify(result._embedded.items))
			}
		});
}

// Delete item from cart
app.delete("/cart/:id", function (req, res, next) {
	if (req.params.id == null) {
		next(new Error("Must pass id of item to delete"), 400);
		return;
	}

	console.log("Request received: " + req.url + ", " + req.params.id);

	// Check if logged in. Get customer Id
	var custId = req.cookies.logged_in;

	// TODO REMOVE THIS, SECURITY RISK
	if (app.get('env') == "development" && req.query.custId != null) {
		custId = req.query.custId;
	}
	// // TODO REMOVE THIS, TESTING
	// custId = 1;

	if (!custId) {
		console.warn("Cannot fetch cart. User not logged in.")
		next(new Error("Cannot fetch cart. User not logged in."), 400);
		return;
	}

	async.waterfall([
// Get carts for current customer Id
			function (callback) {
				var options = {
					uri: cartsUrl + "/search/findByCustomerId?custId=" + custId,
					method: 'GET',
					json: true
				};
				request(options, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("Received response: " + JSON.stringify(body));
					var cartList = body._embedded.carts;
					console.log(JSON.stringify(cartList));
					callback(null, cartList);
				});
			},
			// If the cart doesn't exist, create the cart
			function (cartList, callback) {
				if (cartList.length > 0) {
					console.log("Cart already exists for: " + custId);
					callback(null, cartList[0]._links.cart.href)
				} else {
					console.log("Cart does not exist for: " + custId);
					console.log("Creating cart");
					var options = {
						uri: cartsUrl,
						method: 'POST',
						json: true,
						body: {"customerId": custId}
					};
					request(options, function (error, response, body) {
						if (error) {
							console.log(error);
							callback(true);
							return;
						}
						if (response.statusCode == 201) {
							cartUrl = body._links.cart.href;
							console.log('New cart created for customerId: ' + custId + ', at: ' + cartUrl);
							callback(null, cartUrl)
						} else {
							console.log("Unable to create new cart");
							callback(true);
						}
					});
				}

			},
			// Get items url
			function (cartUrl, callback) {
				var options = {
					uri: cartUrl,
					method: 'GET',
					json: true
				};
				request(options, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("Current cart: " + JSON.stringify(body));
					var itemsUrl = body._links.items.href;
					callback(null, cartUrl, itemsUrl);
				});
			},
			// Get current items
			function (cartUrl, itemsUrl, callback) {
				var options = {
					uri: itemsUrl,
					method: 'GET',
					json: true
				};
				request(options, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("Current items: " + JSON.stringify(body._embedded.items));
					callback(null, itemsUrl, body._embedded.items);
				});
			},
			// Attempt to delete object
			function (currentItemsUrl, itemList, callback) {
				var foundItemUrl = "";
				var currentQuantity = 0;
				console.log("Searching for item in cart of size: " + itemList.length);
				for (var i = 0, len = itemList.length; i < len; i++) {
					var item = itemList[i];
					console.log("Searching: " + JSON.stringify(item));
					console.log("Q: " + item.itemId + " == " + req.params.id);
					if (item != null && item.itemId != null && item.itemId.toString() == req.params.id.toString()) {
						console.log("Item found");
						foundItemUrl = item._links.self.href;
						currentQuantity = item.quantity;
						break;
					}
				}
				if (foundItemUrl != null && foundItemUrl != "") {
					var urlSplit = foundItemUrl.split('/');
					var toDeleteUrl = currentItemsUrl + "/" + urlSplit[urlSplit.length - 1];
					var options = {
						uri: toDeleteUrl,
						method: 'DELETE',
					};
					console.log("toDeleteUrl: " + toDeleteUrl);
					request(options, function (error, response, body) {
						if (error) {
							console.log(error);
							callback(true);
							return;
						}
						console.log('Item deleted from current cart with status: ' + response.statusCode);
						callback(null, response);
					});
				} else {
					callback(new Error("Could not find item in cart to delete.", 404));
				}
			},
		],
		function (err, response) {
			if (err) {
				return next(err);
			}
			res.writeHeader(response.statusCode);
			res.end()
		});
});

// Add new item to cart
app.post("/cart", function (req, res, next) {
	console.log("Request received with body: " + JSON.stringify(req.body));
	console.log("Request received: " + req.url + ", " + req.query.custId);

	if (req.body.id == null) {
		console.warn("Must pass id of item to add.")
		next(new Error("Must pass id of item to add"), 400);
		return;
	}


	// Check if logged in. Get customer Id
	var custId = req.cookies.logged_in;

	// TODO REMOVE THIS, SECURITY RISK
	if (app.get('env') == "development" && req.query.custId != null) {
		custId = req.query.custId;
	}
	// // TODO REMOVE THIS, TESTING
	// custId = 1;
	if (!custId) {
		console.warn("Cannot fetch cart. User not logged in.")
		next(new Error("Cannot fetch cart. User not logged in."), 400);
		return;
	}
	async.waterfall([
			// Get carts for current customer Id
			function (callback) {
				var options = {
					uri: cartsUrl + "/search/findByCustomerId?custId=" + custId,
					method: 'GET',
					json: true
				};
				request(options, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("Received response: " + JSON.stringify(body));
					var cartList = body._embedded.carts;
					console.log(JSON.stringify(cartList));
					callback(null, cartList);
				});
			},
			// If the cart doesn't exist, create the cart
			function (cartList, callback) {
				if (cartList.length > 0) {
					console.log("Cart already exists for: " + custId);
					callback(null, cartList[0]._links.cart.href)
				} else {
					console.log("Cart does not exist for: " + custId);
					console.log("Creating cart");
					var options = {
						uri: cartsUrl,
						method: 'POST',
						json: true,
						body: {"customerId": custId}
					};
					request(options, function (error, response, body) {
						if (error) {
							console.log(error);
							callback(true);
							return;
						}
						if (response.statusCode == 201) {
							cartUrl = body._links.cart.href;
							console.log('New cart created for customerId: ' + custId + ', at: ' + cartUrl);
							callback(null, cartUrl)
						} else {
							console.log("Unable to create new cart");
							callback(true);
						}
					});
				}

			},
			// Get items url
			function (cartUrl, callback) {
				var options = {
					uri: cartUrl,
					method: 'GET',
					json: true
				};
				request(options, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("Current cart: " + JSON.stringify(body));
					var itemsUrl = body._links.items.href;
					callback(null, cartUrl, itemsUrl);
				});
			},
			// Get current items
			function (cartUrl, itemsUrl, callback) {
				var options = {
					uri: itemsUrl,
					method: 'GET',
					json: true
				};
				request(options, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					try {
						console.log("Current items: " + JSON.stringify(body._embedded.items));
						callback(null, itemsUrl, body._embedded.items);
					} catch (e) {
						console.log("Cart is empty");
						callback(null, itemsUrl, []);
					}
				});
			},
			// If new item already exists in list, increment count. Else add new item.
			function (currentItemsUrl, itemList, callback) {
				var foundItemUrl = "";
				var currentQuantity = 0;
				console.log("Searching for item in cart of size: " + itemList.length);
				for (var i = 0, len = itemList.length; i < len; i++) {
					var item = itemList[i];
					console.log("Searching: " + JSON.stringify(item));
					console.log("Q: " + item.itemId + " == " + req.body.id);
					if (item != null && item.itemId != null && item.itemId.toString() == req.body.id.toString()) {
						console.log("Item found");
						foundItemUrl = item._links.self.href;
						currentQuantity = item.quantity;
						break;
					}
				}
				if (foundItemUrl != null && foundItemUrl != "") {
					var options = {
						uri: foundItemUrl,
						method: 'PATCH',
						json: true,
						body: {quantity: (currentQuantity + 1)}
					};
					request(options, function (error, response, body) {
						if (error) {
							console.log(error);
							callback(true);
							return;
						}
						callback(null, body._links.self.href);
					});
				} else {
					// curl -XPOST -H 'Content-type: application/json' http://cart/items -d '{"itemId": "three", "quantity": 4 }'
					// 	curl -v -X POST -H "Content-Type: text/uri-list" -d "http://cart/items/27017283435201488713382769171"
					console.log("Item not found in current cart. Creating new item for: " + req.body.id.toString());
					var options = {
						uri: itemsUrl,
						method: 'POST',
						json: true,
						body: {itemId: req.body.id.toString(), quantity: 1}
					};
					request(options, function (error, response, body) {
						if (error) {
							console.log(error);
							callback(true);
							return;
						}
						if (response.statusCode == 201) {
							console.log('New item created: ' + JSON.stringify(body));
							var newItemUrl = body._links.self.href;
							console.log("Adding item to cart.")
							var options = {
								headers: {
									'Content-Type': 'text/uri-list'
								},
								uri: currentItemsUrl,
								method: 'POST',
								body: body._links.self.href
							};
							request(options, function (error, response, body) {
								if (error) {
									console.log(error);
									callback(true);
									return;
								}
								console.log('New item added to current cart');
								callback(null, newItemUrl);
							});
						} else {
							console.log("Unable to create new item due to: " + JSON.stringify(response) + ", " + JSON.stringify(body));
							callback(true);
						}
					});
				}
			},
			// Get created item
			function (newItemUrl, callback) {
				var options = {
					uri: newItemUrl,
					method: 'GET',
					json: true
				};
				request(options, function (error, response, body) {
					if (error) {
						console.log(error);
						callback(true);
						return;
					}
					console.log("New/updated item: " + JSON.stringify(body));
					callback(null, body);
				});
			},
		],
		function (err, result) {
			if (err) {
				return next(err);
			}

			res.writeHeader(201);
			res.write(JSON.stringify(result));
			res.end()
		});
});

//Orders
app.post("/orders", function(req, res, next) {
	console.log("Request received with body: " + JSON.stringify(req.body));
	async.waterfall([
		function(callback) {
			request(customersUrl + "/" + req.body.customer, function(error, response, body) {
				if (error) {
					console.log(error);
					callback(true);
					return;
				}
				console.log("Received response: " + JSON.stringify(body));
				jsonBody = JSON.parse(body);
				customerlink = jsonBody._links.customer.href;
				addressLink = jsonBody._links.addresses.href;
				cardLink = jsonBody._links.cards.href;
				var order = {
					"customer": customerlink,
					"address": null,
					"card": null,
					"items": null
				}
				callback(null, order, addressLink, cardLink);
			});
		},
		function(order, addressLink, cardLink, callback) {
			async.parallel([
				function(callback) {
					console.log("GET Request to: " + addressLink);
					request.get(addressLink, function(error, response, body) {
						if (error) {
							console.log(error);
							callback(true);
							return;
						}
						console.log("Received response: " + JSON.stringify(body));
						jsonBody = JSON.parse(body);
						order.address = jsonBody._embedded.address[0]._links.self.href;
						callback();
					});
				},
				function(callback) {
					console.log("GET Request to: " + cardLink);
					request.get(cardLink, function(error, response, body) {
						if (error) {
							console.log(error);
							callback(true);
							return;
						}
						console.log("Received response: " + JSON.stringify(body));
						jsonBody = JSON.parse(body);
						order.card = jsonBody._embedded.card[0]._links.self.href;
						callback();
					});
				}
			], function(err, result) {
				if (err) {
					console.log(err);
					return;
				}
				console.log(result);
				callback(null, order);
			});
		},
		function(order, callback) {
			request.get(cartsUrl + "/search/findByCustomerId?custId=" + req.body.customer, function (error, response, body) {
				if (error) {
					console.log(error);
					callback(true);
					return;
				}
				console.log("Received response: " + JSON.stringify(body));
				jsonBody = JSON.parse(body);
				order.items = jsonBody._embedded.carts[0]._links.items.href;
				callback(null, order);
			});
		},
		function(order, callback) {
			var options = {
			  uri: ordersUrl,
			  method: 'POST',
			  json: true,
			  body: order
			};
			console.log("Posting Order: " + order);
			request(options, function(error, response, body) {
				if (error) {
					console.log(error);
					callback(true);
					return;
				}
				// Check for error code
				callback(null, body);
			});
		}
	],
	function(err, result) {
		if (err) { return next(err); }
		res.writeHeader(200);
		res.write(JSON.stringify(result));
		res.end()
	});
});

var server = app.listen(process.env.PORT || 8079, function () {
	var port = server.address().port;
	console.log("App now running on port", port);
});
