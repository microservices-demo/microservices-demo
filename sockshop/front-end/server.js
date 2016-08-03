var request = require('request');
var express = require('express');
var path = require("path");
var bodyParser = require("body-parser");
var async = require("async");
var cookieParser = require("cookie-parser");
var session = require('express-session')

var app = express();
app.use(session({
    secret: 'sooper secret',
    resave: false,
    saveUninitialized: true
}));
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

var domain = "";
process.argv.forEach(function (val, index, array) {
    var arg = val.split("=");
    if (arg.length > 1) {
        if (arg[0] == "--domain") {
            domain = arg[1];
            console.log("Setting domain to:", domain);
        }
    }
});

var catalogueHostname = "catalogue";
var cartsHostname = "cart";
var ordersHostname = "orders";
var accountsHostname = "accounts";
var loginHostname = "login";

function addDomain(hostname) {
    return domain != null && domain != "" ? hostname + "." + domain : hostname;
}

function wrapHttp(host) {
    return "http://" + host;
}

var catalogueUrl = wrapHttp(addDomain(catalogueHostname));
var cartsUrl = wrapHttp(addDomain(cartsHostname)) + "/carts";
var ordersUrl = wrapHttp(addDomain(ordersHostname));
var customersUrl = wrapHttp(addDomain(accountsHostname)) + "/customers";
var addressUrl = wrapHttp(addDomain(accountsHostname)) + "/addresses";
var cardsUrl = wrapHttp(addDomain(accountsHostname)) + "/cards";
var loginUrl = wrapHttp(addDomain(loginHostname)) + "/login";
var registerUrl = wrapHttp(addDomain(loginHostname)) + "/register";
var tagsUrl = catalogueUrl + "/tags";

/**
 * DEVELOPMENT MODE
 * If you are running the front end from your IDE or just in your localhost, first start a proxy
 * on the swarm to proxy all your requests. The request module will then proxy all traffic for you.
 *
 * _Docker Command_
 * See the docs
 */
console.log(app.get('env'));
if (app.get('env') == "development") {
    request = request.defaults({proxy: "http://192.168.99.101:8888"})
}

var cookie_name = 'logged_in';

/**
 * API
 */

// Login
app.get("/login", function (req, res, next) {
    console.log("Received login request");

    async.waterfall([
        function (callback) {
            var options = {
                headers: {
                    'Authorization': req.get('Authorization')
                },
                uri: loginUrl
            };
            request(options, function (error, response, body) {
                if (error) {
                    callback(error);
                    return;
                }
                if (response.statusCode == 200 && body != null && body != "") {
                    console.log(body);
                    customerId = JSON.parse(body).user.id;
                    console.log(customerId);
                    callback(null, customerId);
                    return;
                }
                console.log(response.statusCode);
                callback(true);
            });
        },
        function (custId, callback) {
            var sessionId = req.session.id;
            console.log("Merging carts for customer id: " + custId + " and session id: " + sessionId);

            var options = {
                uri: cartsUrl + "/" + custId + "/merge" + "?sessionId=" + sessionId,
                method: 'GET'
            };
            request(options, function (error, response, body) {
                if (error) {
                    callback(error);
                    return;
                }
                console.log('Carts merged.');
                callback(null, custId);
            });
        }
    ],
    function (err, custId) {
        if (err) {
            console.log("Error with log in: " + err);
            res.status(401);
            res.end();
            return;
        }
        res.status(200);
        res.cookie(cookie_name, custId, {maxAge: 3600000}).send('Cookie is set');
        console.log("Sent cookies.");
        res.end();
        return;
    });
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
    console.log("Posting Customer: " + JSON.stringify(req.body));
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
    console.log("Posting Address: " + JSON.stringify(req.body));
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
    console.log("Posting Card: " + JSON.stringify(req.body));
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

// Accounts
app.get("/accounts/:id", function (req, res, next) {
    simpleHttpRequest(customersUrl + "/" + req.params.id, res, next);
});

//Carts
// List items in cart for current logged in user.
app.get("/cart", function (req, res, next) {
    console.log("Request received: " + req.url + ", " + req.query.custId);
    var custId = getCustomerId(req);
    console.log("Customer ID: " + custId);
    request(cartsUrl + "/" + custId + "/items", function (error, response, body) {
        if (error) {
            return next(error);
        }
        respondStatusBody(res, response.statusCode, body)
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
        respondStatus(res, response.statusCode);
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
        respondStatus(res, response.statusCode);
    });
});

// Add new item to cart
app.post("/cart", function (req, res, next) {
    console.log("Attempting to add to cart: " + JSON.stringify(req.body));

    if (req.body.id == null) {
        next(new Error("Must pass id of item to add"), 400);
        return;
    }

    var custId = getCustomerId(req);

    async.waterfall([
        function (callback) {
            request(catalogueUrl + "/catalogue/" + req.body.id.toString(), function (error, response, body) {
                console.log(body);
                callback(error, JSON.parse(body));
            });
        },
        function (item, callback) {
            var options = {
                uri: cartsUrl + "/" + custId + "/items",
                method: 'POST',
                json: true,
                body: {itemId: item.id, unitPrice: item.price}
            };
            console.log("POST to carts: " + options.uri + " body: " + JSON.stringify(options.body));
            request(options, function (error, response, body) {
                if (error) {
                    callback(error)
                    return;
                }
                callback(null, response.statusCode);
            });
        }
    ], function (err, statusCode) {
        if (err) {
            return next(err);
        }
        if (statusCode != 201) {
            return next(new Error("Unable to add to cart. Status code: " + statusCode))
        }
        respondStatus(res, statusCode);
    });
});

//Orders
app.get("/orders", function (req, res, next) {
    console.log("Request received with body: " + JSON.stringify(req.body));
    // var custId = getCustomerId(req);
    var custId = req.cookies.logged_in;
    if (!custId) {
        throw new Error("User not logged in.");
        return
    }

    async.waterfall([
            function (callback) {
                request(ordersUrl + "/orders/search/customerId?sort=date&custId=" + custId, function (error, response, body) {
                    if (error) {
                        return callback(error);
                    }
                    console.log("Received response: " + JSON.stringify(body));
                    if (response.statusCode == 404) {
                        console.log("No orders found for user: " + custId);
                        return callback(null, []);
                    }
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

app.get("/orders/*", function (req, res, next) {
    var url = ordersUrl + req.url.toString();
    request.get(url).pipe(res);
});

app.post("/orders", function(req, res, next) {
    console.log("Request received with body: " + JSON.stringify(req.body));
    // var custId = getCustomerId(req);
    var custId = req.cookies.logged_in;
    if (!custId) {
        throw new Error("User not logged in.");
        return
    }

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
                        "customer": customerlink,
                        "address": null,
                        "card": null,
                        "items": cartsUrl + "/" + custId + "/items"
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
                                return;
                            }
                            console.log("Received response: " + JSON.stringify(body));
                            jsonBody = JSON.parse(body);
                            if (jsonBody._embedded.address[0] != null) {
                                order.address = jsonBody._embedded.address[0]._links.self.href;
                            }
                            callback();
                        });
                    },
                    function (callback) {
                        console.log("GET Request to: " + cardLink);
                        request.get(cardLink, function (error, response, body) {
                            if (error) {
                                callback(error);
                                return;
                            }
                            console.log("Received response: " + JSON.stringify(body));
                            jsonBody = JSON.parse(body);
                            if (jsonBody._embedded.card[0] != null) {
                                order.card = jsonBody._embedded.card[0]._links.self.href;
                            }
                            callback();
                        });
                    }
                ], function (err, result) {
                    if (err) {
                        callback(err);
                        return;
                    }
                    console.log(result);
                    callback(null, order);
                });
            },
            function (order, callback) {
                var options = {
                    uri: ordersUrl + '/orders',
                    method: 'POST',
                    json: true,
                    body: order
                };
                console.log("Posting Order: " + JSON.stringify(order));
                request(options, function (error, response, body) {
                    if (error) {
                        return callback(error);
                    }
                    console.log("Order response: " + JSON.stringify(response));
                    console.log("Order response: " + JSON.stringify(body));
                    callback(null, response.statusCode, body);
                });
            }
        ],
        function (err, status, result) {
            if (err) {
                return next(err);
            }
            respondStatusBody(res, status, JSON.stringify(result));
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

function respondStatus(res, statusCode) {
    res.writeHeader(statusCode);
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
        if (!req.session.id) {
           throw new Error("User not logged in.");
        }
        // Use Session ID instead
        return req.session.id;
    }

    return custId;
}


// Get the current user's cart url. Create a new cart if one doesn't exist.
// Returns: Url of user's cart
function getCartUrlForCustomerId(custId, callback) {
    async.waterfall([
            function (callback) {
                var options = {
                    uri: cartsUrl + "/search/findByCustomerId?custId=" + custId,
                    method: 'GET',
                    json: true
                };
                request(options, function (error, response, body) {
                    if (error) {
                        return callback(error);
                    }
                    console.log("Received response: " + JSON.stringify(body));
                    var cartList = body._embedded.carts;
                    console.log(JSON.stringify(cartList));
                    callback(null, cartList);
                });
            },
            function (cartList, callback) {
                if (cartList.length == 0) {
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
                            callback(error);
                            return;
                        }
                        if (response.statusCode == 201) {
                            cartList.push(body);
                            console.log('New cart created for customerId: ' + custId + ': ' + JSON.stringify(body));
                            callback(null, cartList);
                            return;
                        }
                        callback("Unable to create new cart. Body: " + JSON.stringify(body));
                        return;
                    });
                } else {
                    callback(null, cartList)
                }
            },
            function (cartList, callback) {
                var cartUrl = cartList[0]._links.cart.href;
                console.log("Using cart url: " + cartUrl);
                callback(null, cartUrl);
            }
        ],
        function (err, cartUrl) {
            callback(err, cartUrl);
        });
}

// Get cart items
// Parameters:  cartUrl:    URL of the current cart
// Returns:     itemsUrl:   Url of the current item list
//              items:      All of the current cart's items
function getCartItems(cartUrl, callback) {
    async.waterfall([
            // Get items url
            function (callback) {
                var options = {
                    uri: cartUrl,
                    method: 'GET',
                    json: true
                };
                request(options, function (error, response, body) {
                    if (error) {
                        callback(error);
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
                        callback(error);
                        return;
                    }
                    console.log("Current items: " + JSON.stringify(body._embedded.items));
                    callback(null, itemsUrl, body._embedded.items);
                });
            }
        ],
        function (err, currentItemsUrl, itemList) {
            callback(err, currentItemsUrl, itemList);
        });

}


// Find an item in a list
// Inputs:  itemList    -   List of items
//          idemId      -   ID of the item to find
// Returns: { url: Url pointing to the item,
//            quantity: Current quantity }
function findItem(itemList, itemId) {
    var foundItemUrl = "";
    var currentQuantity = 0;
    console.log("Searching for item in cart of size: " + itemList.length);
    for (var i = 0, len = itemList.length; i < len; i++) {
        var item = itemList[i];
        console.log("Searching: " + JSON.stringify(item));
        console.log("Q: " + item.itemId + " == " + itemId);
        if (item != null && item.itemId != null && item.itemId.toString() == itemId) {
            console.log("Item found");
            foundItemUrl = item._links.self.href;
            currentQuantity = item.quantity;
            break;
        }
        // Use Session ID instead
        return req.session.id;
        // throw new Error("User not logged in.");
    }

    return custId;
}
