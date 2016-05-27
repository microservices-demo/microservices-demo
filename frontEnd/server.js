var request = require('request');
var express = require('express');
var path = require("path");
var bodyParser = require("body-parser");
var async = require("async");

var app = express();
app.use(express.static(__dirname + "/"));
app.use(bodyParser.json());

var catalogueUrl = "http://catalogue/catalogue";
var accountsUrl = "http://accounts/accounts";
var cartsUrl = "http://carts/carts";
var ordersUrl = "http://orders/orders";
var itemsUrl = "http://items/items";
var customersUrl = "http://accounts/customers";

// if (app.get('env') == "development") {
// 	catalogueUrl = "http://localhost:8084/catalogue";
// 	accountsUrl = "http://localhost:8082/accounts";
// 	cartsUrl = "http://localhost:8081/carts";
// 	itemsUrl = "http://localhost:8081/items";
// 	ordersUrl = "http://localhost:8083/orders";
// 	customersUrl = "http://localhost:8082/customers";
// }

function handleError(res, reason, message, code) {
	console.log("Error: " + reason);
	res.status(code || 500).json({"error": message});
}

// Catalogue
app.get("/catalogue", function(req, res) {
	console.log("Received request: " + req);
	request(catalogueUrl, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  } else {
		  	console.log(error)
		  	console.log(response.statusCode)
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/catalogue/:id", function(req, res) {

	request(catalogueUrl + "/" + req.params.id, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  } else {
		  	console.log(error)
		  	console.log(response.statusCode)
		  	return;
		  }
	}.bind( {res: res} ));
});

// Accounts
app.get("/accounts/", function(req, res) {

	request(accountsUrl + "?custId=1", function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  } else {
		  	console.log(error)
		  	console.log(response.statusCode)
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/accounts/:id", function(req, res) {

	request(accountsUrl + "/" + req.params.id, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  } else {
		  	console.log(error)
		  	console.log(response.statusCode)
		  	return;
		  }
	}.bind( {res: res} ));
});

//Carts
app.get("/carts", function(req, res) {
	console.log("Request received: " + req.url);
	request.get(cartsUrl + "/search/findByCustomerId?custId=1", function (error, response, body) {
		console.log("Response received from carts.");
		if (!error && response.statusCode == 200) {
		    // console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  } else {
		  	console.log(error)
		  	console.log(response.statusCode)
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/carts/:cartId", function(req, res) {
	console.log("Request received: " + req.url);
	async.waterfall([
		function(callback) {
			request.get(cartsUrl + "/" + req.params.cartId, function(error, response, body) {
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
		function(arg1, callback) {
			request.get(arg1, function(error, response, body) {
				if (error) {
					console.log(error);
					callback(true);
					return;
				}
				console.log("Received response: " + JSON.stringify(body));
				callback(null, JSON.parse(body));
			});
		}
	],
	function(err, result) {
		res.writeHeader(200);
		// res.writeJs(result._embedded.items);
		res.end(JSON.stringify(result._embedded.items))
	});
});

app.post("/carts/:cartId/items", function(req, res) {
	console.log("Request received with body: " + JSON.stringify(req.body));
	async.waterfall([
		function(callback) {
			var options = {
			  uri: itemsUrl,
			  method: 'POST',
			  json: true,
			  body: req.body
			};
			request(options, function(error, response, body) {
				if (error) {
					console.log(error);
					callback(true);
					return;
				}
				console.log("Received response: " + JSON.stringify(body));
				// jsonBody = JSON.parse(body);
				link = body._links.item.href;
				callback(null, link);
			});
		},
		function(arg1, callback) {
			var options = {
				headers: {
					'Content-Type': 'text/uri-list'
				},
				uri: cartsUrl + "/" + req.params.cartId + "/items",
				method: 'POST',
				body: arg1
			};
			request(options, function(error, response, body) {
				if (error) {
					console.log(error);
					callback(true);
					return;
				}
				cartItem = body;
				callback(null, cartItem);
			});
		}
	],
	function(err, result) {
		res.writeHeader(200);
		res.write(JSON.stringify(result));
		res.end()
	});
});

//Orders
app.post("/orders", function(req, res) {
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
					"address": addressLink,
					"card": cardLink,
					"items": null
				}
				callback(null, order);
			});
		},
		function(arg1, callback) {
			request.get(cartsUrl + "/search/findByCustomerId?custId=1", function (error, response, body) {
				if (error) {
					console.log(error);
					callback(true);
					return;
				}
				console.log("Received response: " + JSON.stringify(body));
				jsonBody = JSON.parse(body);
				arg1.items = jsonBody._embedded.carts[0]._links.items.href;
				callback(null, arg1);
			});
		}
	],
	function(err, result) {
		res.writeHeader(200);
		res.write(JSON.stringify(result));
		res.end()
	});
});

var server = app.listen(process.env.PORT || 8079, function () {
	var port = server.address().port;
	console.log("App now running on port", port);
});