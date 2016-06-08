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
    saveUninitialized: false
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
                }
                if (response.statusCode == 200 && body != null && body != "") {
                    console.log(body);
                    customerId = JSON.parse(body).id;
                    console.log(customerId);
                    callback(customerId);
                } else {
                    console.log(response.statusCode);
                    callback(true);
                }
            });
        },
        function (custId, callback) {
            var sessionId = req.session.id;
            console.log("Merging carts for customer id: " + custId + " and session id: " + sessionId);

            var options = {
                uri: cartsUrl + "/merge?custId=" + custId + "&sessionId=" + sessionId,
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

    async.waterfall([
            async.apply(getCartUrlForCustomerId, custId),
            getCartItems
        ],
        function (err, currentItemsUrl, itemList) {
            if (err) {
                return next(err);
            }
            respondSuccessBody(res, JSON.stringify(itemList))
        }.bind({res: res}));
});

// Delete cart
app.delete("/cart", function (req, res, next) {
    var custId = getCustomerId(req);
    async.waterfall([
            async.apply(getCartUrlForCustomerId, custId),
            deleteItem
        ],
        function (err, response) {
            if (err) {
                return next(err);
            }
            res.writeHeader(response.statusCode);
            res.end()
        });
});

// Delete item from cart
app.delete("/cart/:id", function (req, res, next) {
    if (req.params.id == null) {
        next(new Error("Must pass id of item to delete"), 400);
        return;
    }

    console.log("Delete item from cart: " + req.url);

    var custId = getCustomerId(req);

    async.waterfall([
            async.apply(getCartUrlForCustomerId, custId),
            getCartItems,
            // Attempt to delete object
            function (currentItemsUrl, itemList, callback) {
                var foundItem = findItem(itemList, req.params.id.toString());
                if (foundItem.url != null && foundItem.url != "") {
                    var urlSplit = foundItem.url.split('/');
                    var toDeleteUrl = currentItemsUrl + "/" + urlSplit[urlSplit.length - 1];
                    deleteItem(toDeleteUrl, callback);
                } else {
                    callback(new Error("Could not find item in cart to delete.", 404));
                }
            }
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

    if (req.body.id == null) {
        next(new Error("Must pass id of item to add"), 400);
        return;
    }

    var custId = getCustomerId(req);

    async.waterfall([
            async.apply(getCartUrlForCustomerId, custId),
            getCartItems,
            // If new item already exists in list, increment count. Else add new item.
            function (currentItemsUrl, itemList, callback) {
                var foundItem = findItem(itemList, req.body.id.toString());
                if (foundItem.url != null && foundItem.url != "") {
                    var options = {
                        uri: foundItem.url,
                        method: 'PATCH',
                        json: true,
                        body: {quantity: (foundItem.quantity + 1)}
                    };
                    request(options, function (error, response, body) {
                        if (error) {
                            callback(error);
                            return;
                        }
                        callback(null, body._links.self.href);
                    });
                } else {
                    // curl -XPOST -H 'Content-type: application/json' http://cart/items -d '{"itemId": "three", "quantity": 4 }'
                    // 	curl -v -X POST -H "Content-Type: text/uri-list" -d "http://cart/items/27017283435201488713382769171"
                    console.log("Item not found in current cart. Creating new item for: " + req.body.id.toString());
                    async.waterfall([
                            function (callback) {
                                request.get(catalogueUrl + "/catalogue/" + req.body.id.toString(), function (error, response, body) {
                                    if (error) {
                                        return next(error);
                                    }
                                    console.log("Item from catalogue: " + body);
                                    callback(null, currentItemsUrl, req.body.id.toString(), JSON.parse(body));
                                });
                            },
                            createNewItem,
                            addItemToCart
                        ],
                        function (err, newItemUrl) {
                            callback(err, newItemUrl);
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
                        callback(error);
                        return;
                    }
                    console.log("New/updated item: " + JSON.stringify(body));
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
                        async.apply(getCartUrlForCustomerId, custId),
                        getCartItems
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
        if (!req.session.id) {
            throw new Error("wAT!?!?");
        }
        // Use Session ID instead
        return req.session.id;
        // throw new Error("User not logged in.");
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
                            callback(null, cartList)
                        } else {
                            callback("Unable to create new cart. Body: " + JSON.stringify(body));
                            return;
                        }
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
    }
    return {
        url: foundItemUrl,
        quantity: currentQuantity
    }
}

// Create a new item
// Inputs:  currentItemsUrl - Url of current list of items
//          itemId - Id of item you want to create
// Returns: currentItemsUrl - Url of current list of items
//          newItemUrl - Url pointing to new item
function createNewItem(currentItemsUrl, itemId, item, callback) {
    var options = {
        uri: itemsUrl,
        method: 'POST',
        json: true,
        body: {itemId: itemId, quantity: 1, unitPrice: item.price}
    };
    request(options, function (error, response, body) {
        if (error) {
            callback(error);
            return;
        }
        if (response.statusCode == 201) {
            console.log('New item created: ' + JSON.stringify(body));
            var newItemUrl = body._links.self.href;
            callback(null, currentItemsUrl, newItemUrl);
        } else {
            callback(new Error("Unable to create new item due to: " + JSON.stringify(response) + ", " + JSON.stringify(body)));
            return;
        }
    });
}

// Add newly created item to the cart
// Inputs:  currentItemsUrl - Url of current list of items
//          newItemUrl - Url pointing to new item
// Returns: newItemUrl - Url pointing to new item
function addItemToCart(currentItemsUrl, newItemUrl, callback) {
    console.log("Adding item to cart: " + newItemUrl);
    var options = {
        headers: {
            'Content-Type': 'text/uri-list'
        },
        uri: currentItemsUrl,
        method: 'POST',
        body: newItemUrl
    };
    request(options, function (error, response, body) {
        if (error) {
            callback(error);
            return;
        }
        console.log('New item added to current cart');
        callback(null, newItemUrl);
    });
}

// Delete something
// Inputs:  toDeleteUrl - URL to delete
// Returns: response - The response from the delete call
function deleteItem(toDeleteUrl, callback) {
    var options = {
        uri: toDeleteUrl,
        method: 'DELETE'
    };
    console.log("toDeleteUrl: " + toDeleteUrl);
    request(options, function (error, response, body) {
        if (error) {
            return callback(error);
        }
        console.log('Item deleted with status: ' + response.statusCode);
        callback(null, response);
    });
}