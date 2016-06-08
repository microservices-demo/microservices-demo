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
var addressUrl = "http://accounts/addresses";
var cardsUrl = "http://accounts/cards";
var loginUrl = "http://login/login";
var registerUrl = "http://login/register";
var tagsUrl = catalogueUrl + "/tags";

console.log(app.get('env'));
if (app.get('env') == "development") {
    catalogueUrl = "http://192.168.99.101:32770";
    accountsUrl = "http://localhost:8082/accounts";
    cartsUrl = "http://192.168.99.102:32771/carts";
    itemsUrl = "http://192.168.99.102:32771/items";
    ordersUrl = "http://192.168.99.103:32768/orders";
    customersUrl = "http://192.168.99.102:32769/customers";
    addressUrl = "http://192.168.99.102:32769/addresses";
    cardsUrl = "http://192.168.99.102:32769/cards";
    loginUrl = "http://192.168.99.103:32769/login";
    registerUrl = "http://localhost:8084/register";
    tagsUrl = catalogueUrl + "/tags";
}

// TODO Add logging

var cookie_name = 'logged_in';

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

// Register - TO BE USED FOR TESTING ONLY (for now)
app.get("/register", function(req, res, next) {
    simpleHttpRequest(registerUrl + "?username=" + req.query.username + "&password=" + req.query.password, res, next);
});

// Create Customer - TO BE USED FOR TESTING ONLY (for now)
app.post("/customers", function(req, res, next) {
    var options = {
        uri: customersUrl,
        method: 'POST',
        json: true,
        body: req.body
    };
    console.log("Posting Customer: " + req.body);
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondSuccessBody(res, JSON.stringify(body));
    }.bind({res: res}));
});

// Create Address - TO BE USED FOR TESTING ONLY (for now)
app.post("/addresses", function(req, res, next) {
    var options = {
        uri: addressUrl,
        method: 'POST',
        json: true,
        body: req.body
    };
    console.log("Posting Address: " + req.body);
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondSuccessBody(res, JSON.stringify(body));
    }.bind({res: res}));
});

// Create Card - TO BE USED FOR TESTING ONLY (for now)
app.post("/cards", function(req, res, next) {
    var options = {
        uri: cardsUrl,
        method: 'POST',
        json: true,
        body: req.body
    };
    console.log("Posting Card: " + req.body);
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondSuccessBody(res, JSON.stringify(body));
    }.bind({res: res}));
});

// Delete Customer - TO BE USED FOR TESTING ONLY (for now)
app.delete("/customers/:id", function(req, res, next) {
    console.log("Deleting Customer " + req.params.id);
    var options = {
        uri: customersUrl + "/" + req.params.id,
        method: 'DELETE'
    };
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondSuccessBody(res, JSON.stringify(body));
    }.bind({res: res}));
});

// Delete Address - TO BE USED FOR TESTING ONLY (for now)
app.delete("/addresses/:id", function(req, res, next) {
    console.log("Deleting Address " + req.params.id);
    var options = {
        uri: addressUrl + "/" + req.params.id,
        method: 'DELETE'
    };
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondSuccessBody(res, JSON.stringify(body));
    }.bind({res: res}));
});

// Delete Card - TO BE USED FOR TESTING ONLY (for now)
app.delete("/cards/:id", function(req, res, next) {
    console.log("Deleting Card " + req.params.id);
    var options = {
        uri: cardsUrl + "/" + req.params.id,
        method: 'DELETE'
    };
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondSuccessBody(res, JSON.stringify(body));
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
app.get("/cart", function (req, res) {
    console.log("Request received: " + req.url + ", " + req.query.custId);
    var custId = getCustomerId(req);

    request(cartsUrl + "/" + custId + "/items", function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondStatusBody(res, response.statusCode, JSON.stringify(body))
    });
});

// Delete cart
app.delete("/cart", function (req, res, next) {
    var custId = getCustomerId(req);
    console.log('Attempting to delete cart for user: ' + custId);
    var options = {
        uri: cartsUrl + "/" + custId,
        method: 'DELETE'
    };
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        console.log('User cart deleted with status: ' + response.statusCode);
        respondStatusBody(res, response.statusCode, null);
    });
});

// Delete item from cart
app.delete("/cart/:id", function (req, res, next) {
    if (req.params.id == null) {
        return next(new Error("Must pass id of item to delete"), 400);
    }

    console.log("Delete item from cart: " + req.url);

    var custId = getCustomerId(req);

    var options = {
        uri: cartsUrl + "/" + custId + "/items/" + req.params.id.toString(),
        method: 'DELETE'
    };
    request(options, function (error, response, body) {
        if (error) {
            return next(error);
        }
        console.log('Item deleted with status: ' + response.statusCode);
        respondStatusBody(res, response.statusCode, null);
    });
});

// Add new item to cart
app.post("/cart", function (req, res, next) {
    console.log("Request received with body: " + JSON.stringify(req.body));

    if (req.body.id == null) {
        next(new Error("Must pass id of item to add"), 400);
        return;
    }

    var custId = getCustomerId(req);

    var options = {
        uri: cartsUrl + "/" + custId + "/items",
        method: 'POST',
        json: true,
        body: {itemId: req.body.id.toString()}
    };
    request(options, function (error, response, body) {
        if (error) {
            return callback(error);
        }
        console.log('Item deleted with status: ' + response.statusCode);
        respondStatusBody(res, response.statusCode, null);
    });
});

//Orders
app.get("/orders", function (req, res, next) {
    console.log("Request received with body: " + JSON.stringify(req.body));
    var custId = getCustomerId(req);

    async.waterfall([
            function (callback) {
                request(ordersUrl + "/search/customerId?sort=date&custId=" + custId, function (error, response, body) {
                    if (error) {
                        return callback(error);
                    }
                    console.log("Received response: " + JSON.stringify(body));
                    callback(null, JSON.parse(body)._embedded.customerOrders);
                });
            }
        ],
        function (err, result) {
            if (err) {
                return next(err);
            }
            respondStatusBody(res, 201, JSON.stringify(result));
        });
});

app.post("/orders", function(req, res, next) {
    console.log("Request received with body: " + JSON.stringify(req.body));
    var custId = getCustomerId(req);

    async.waterfall([
            function (callback) {
                request(customersUrl + "/" + custId, function (error, response, body) {
                    if (error) {
                        callback(error);
                        return;
                    }
                    console.log("Received response: " + JSON.stringify(body));
                    jsonBody = JSON.parse(body);
                    customerlink = jsonBody._links.customer.href;
                    addressLink = jsonBody._links.addresses.href;
                    cardLink = jsonBody._links.cards.href;
                    var order = {
                        "customerId": custId,
                        "customer": customerlink,
                        "address": null,
                        "card": null,
                        "items": null,
                        "total": null
                    };
                    callback(null, order, addressLink, cardLink);
                });
            },
            function (order, addressLink, cardLink, callback) {
                async.parallel([
                    function (callback) {
                        console.log("GET Request to: " + addressLink);
                        request.get(addressLink, function (error, response, body) {
                            if (error) {
                                callback(error);
                            }
                            console.log("Received response: " + JSON.stringify(body));
                            jsonBody = JSON.parse(body);
                            // TODO Temp Hack/fix :)
                            // order.address = jsonBody._embedded.address[0]._links.self.href;
                            order.address = addressLink
                            callback();
                        });
                    },
                    function (callback) {
                        console.log("GET Request to: " + cardLink);
                        request.get(cardLink, function (error, response, body) {
                            if (error) {
                                callback(error);
                            }
                            console.log("Received response: " + JSON.stringify(body));
                            jsonBody = JSON.parse(body);
                            // TODO Temp Hack/fix :)
                            // order.card = jsonBody._embedded.card[0]._links.self.href;
                            order.card = cardLink
                            callback();
                        });
                    }
                ], function (err, result) {
                    if (err) {
                        callback(err);
                    }
                    console.log(result);
                    callback(null, order);
                });
            },
            function (order, callback) {
                async.waterfall([
                        function (callback) {
                            request(cartsUrl + "/" + custId + "/items", function (error, response, body) {
                                if (error) {
                                    return callback(error);
                                }
                                callback(null, cartsUrl + "/" + custId + "/items", JSON.stringify(body))
                            });
                        }
                    ],
                    function (err, currentItemsUrl, itemList) {
                        if (err) {
                            return callback(err);
                        }
                        console.log("Summing cart.");
                        var sum = 0;
                        for (var i = 0; i < itemList.length; i++) {
                            sum = sum + itemList[i].quantity * itemList[i].unitPrice;
                        }
                        order.items = currentItemsUrl;
                        order.total = sum;
                        callback(null, order);
                    });
            },
            function (order, callback) {
                var options = {
                    uri: ordersUrl,
                    method: 'POST',
                    json: true,
                    body: order
                };
                console.log("Posting Order: " + JSON.stringify(order));
                request(options, function (error, response, body) {
                    if (error) {
                        return callback(error);
                    }
                    console.log("Order response: " + JSON.stringify(body));
                    // Check for error code
                    callback(null, body);
                });
            }
        ],
        function (err, result) {
            if (err) {
                return next(err);
            }
            respondStatusBody(res, 201, JSON.stringify(result));
        });
});

var server = app.listen(process.env.PORT || 8079, function () {
    var port = server.address().port;
    console.log("App now running on port", port);
});


/**
 * HELPERS
 */

function respondSuccessBody(res, body) {
    respondStatusBody(res, 200, body);
}

function respondStatusBody(res, statusCode, body) {
    console.log(body);
    res.writeHeader(statusCode);
    res.write(body);
    res.end()
}

function simpleHttpRequest(url, res, next) {
    console.log("GET " + url);
    request.get(url, function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondSuccessBody(res, body);
    }.bind({res: res}));
}

// Returns the customerId of the current user
// Return: customer Id
// Throws: Error when user is not logged in.
function getCustomerId(req) {
    // Check if logged in. Get customer Id
    var custId = req.cookies.logged_in;

    // TODO REMOVE THIS, SECURITY RISK
    if (app.get('env') == "development" && req.query.custId != null) {
        custId = req.query.custId;
    }

    if (!custId) {
        throw new Error("User not logged in.");
    }

    return custId;
}