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

var catalogueUrl = "http://catalogue/catalogue";
var accountsUrl = "http://accounts/accounts";
var cartsUrl = "http://cart/carts";
var ordersUrl = "http://orders/orders";
var itemsUrl = "http://cart/items";
var customersUrl = "http://accounts/customers";
var loginUrl = "http://login/login";
var tagsUrl = "http://catalogue/tags";
var imagesUrl = "http://catalogue/images";

console.log(app.get('env'));
if (app.get('env') == "development") {
	catalogueUrl = "http://localhost:8081/catalogue";
	accountsUrl = "http://localhost:8082/accounts";
	cartsUrl = "http://localhost:8081/carts";
	itemsUrl = "http://localhost:8081/items";
	ordersUrl = "http://localhost:8083/orders";
	customersUrl = "http://localhost:8082/customers";
	loginUrl = "http://localhost:8084/login";
	tagsUrl = "http://localhost:8081/tags";
	imagesUrl = "http://localhost:8081/images";
}

// TODO Add logging

var cookie_name = 'logged_in';

/**
 * API
 */

// Login
app.get("/login", function(req, res, next) {
	console.log("Received login request: " + req);
	var options = {
	  headers: {
	  	'Authorization': req.get('Authorization')
	  },
	  uri: loginUrl
	};
	res.status(200);
	request(options, function(error, response, body) {
		if (error) { return next(error); }
		if (response.statusCode == 200 && body != null && body != "") {
		    console.log(body);
			customerId = JSON.parse(body).id;
			console.log(customerId);
			res.cookie(cookie_name, customerId, {maxAge: 3600000}).send('Cookie is set');
			console.log("Sent cookies.")
			return
		} else {
		   	console.log(response.statusCode);
		}
		res.status(401);
		res.end();
	}.bind( {res: res} ));
});

// Catalogue
app.get("/catalogue*", function(req, res, next) {
	console.log("Received request: " + req);
	request("http://localhost:8081" + req.url, function (error, response, body) {
		if (error) { return next(error); }
		if (response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end();
		  } else {
		   	console.log(response.statusCode);
		   	res.status(response.statusCode);
		   	res.end();
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/tags", function(req, res, next) {
	request(tagsUrl, function (error, response, body) {
		if (error) { return next(error); }
		if (response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end();
		  } else {
		   	console.log(response.statusCode);
		   	res.status(response.statusCode);
		   	res.end();
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/images/:id", function(req, res, next) {
	request(imagesUrl + "/" + req.params.id, function (error, response, body) {
		if (error) { return next(error); }
		if (response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end();
		  } else {
		   	console.log(response.statusCode);
		   	res.status(response.statusCode);
		   	res.end();
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/catalogue/:id", function(req, res, next) {

	request(catalogueUrl + "/" + req.params.id, function (error, response, body) {
		if (error) { return next(error); }
		if (response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end();
		  } else {
		   	console.log(response.statusCode);
		   	res.status(response.statusCode);
		   	res.end();
		  	return;
		  }
	}.bind( {res: res} ));
});

// Accounts
app.get("/accounts/", function(req, res, next) {

	var custId = req.params.custId;
	if (!custId) {
		custId = req.cookies.logged_in;	
	}
	if (!custId) {
		custId = "1";
	}
	request(accountsUrl + "?custId=" + custId, function (error, response, body) {
		if (error) { return next(error); }
		if (response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end();
		  } else {
		   	console.log(response.statusCode);
		   	res.status(response.statusCode);
		   	res.end();
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/accounts/:id", function(req, res, next) {

	request(accountsUrl + "/" + req.params.id, function (error, response, body) {
		if (error) { return next(error); }
		if (response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end();
		  } else {
		   	console.log(response.statusCode);
		  	res.status(response.statusCode);
		  	res.end();
		  	return;
		  }
	}.bind( {res: res} ));
});

//Carts
app.get("/carts", function(req, res, next) {
	console.log("Request received: " + req.url);
	var custId = req.params.custId;
	if (!custId) {
		custId = req.cookies.logged_in;	
	}
	if (!custId) {
		custId = "1";
	}
	request.get(cartsUrl + "/search/findByCustomerId?custId=" + custId, function (error, response, body) {
		if (error) { return next(error); }
		console.log("Response received from carts.");
		if (response.statusCode == 200) {
		    // console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end();
		  } else {
		   	console.log(response.statusCode);
		   	res.status(response.statusCode);
		   	res.end();
		  	return;
		  }
	}.bind( {res: res} ));
});

app.get("/carts/:cartId", function(req, res, next) {
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
		if (err) { return next(err); }
		res.writeHeader(200);
		// res.writeJs(result._embedded.items);
		res.end(JSON.stringify(result._embedded.items))
	});
});

app.post("/carts/:cartId/items", function(req, res, next) {
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
		if (err) { return next(err); }
		
		res.writeHeader(200);
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
