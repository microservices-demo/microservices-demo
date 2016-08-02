var request = require('request');
var express = require('express');
var path = require("path");
var bodyParser = require("body-parser");
var async = require("async");
var cookieParser = require("cookie-parser");
var session = require('express-session')
var helpers = require("./helpers");

var app = express(),
    env = app.get("env");

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
if (env == "development") {
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
  helpers.simpleHttpRequest(registerUrl + "?username=" + req.query.username + "&password=" + req.query.password, res, next);
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
    helpers.respondSuccessBody(res, JSON.stringify(body));
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
    helpers.respondSuccessBody(res, JSON.stringify(body));
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
    helpers.respondSuccessBody(res, JSON.stringify(body));
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
    helpers.respondSuccessBody(res, JSON.stringify(body));
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
    helpers.respondSuccessBody(res, JSON.stringify(body));
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
    helpers.respondSuccessBody(res, JSON.stringify(body));
  }.bind({res: res}));
});

// Catalogue
app.get("/catalogue/images*", function (req, res, next) {
  var url = catalogueUrl + req.url.toString();
  request.get(url).pipe(res);
});

app.get("/catalogue*", function (req, res, next) {
  helpers.simpleHttpRequest(catalogueUrl + req.url.toString(), res, next);
});

app.get("/tags", function(req, res, next) {
  helpers.simpleHttpRequest(tagsUrl, res, next);
});

// Accounts
app.get("/accounts/:id", function (req, res, next) {
  helpers.simpleHttpRequest(customersUrl + "/" + req.params.id, res, next);
});

//Carts
// List items in cart for current logged in user.
app.get("/cart", function (req, res, next) {
  console.log("Request received: " + req.url + ", " + req.query.custId);
  var custId = helpers.getCustomerId(req, env);
  console.log("Customer ID: " + custId);
  request(cartsUrl + "/" + custId + "/items", function (error, response, body) {
    if (error) {
      return next(error);
    }
    helpers.respondStatusBody(res, response.statusCode, body)
  });
});

// Delete cart
app.delete("/cart", function (req, res, next) {
  var custId = helpers.getCustomerId(req, env);
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
    helpers.respondStatus(res, response.statusCode);
  });
});

// Delete item from cart
app.delete("/cart/:id", function (req, res, next) {
  if (req.params.id == null) {
    return next(new Error("Must pass id of item to delete"), 400);
  }

  console.log("Delete item from cart: " + req.url);

  var custId = helpers.getCustomerId(req, env);

  var options = {
    uri: cartsUrl + "/" + custId + "/items/" + req.params.id.toString(),
    method: 'DELETE'
  };
  request(options, function (error, response, body) {
    if (error) {
      return next(error);
    }
    console.log('Item deleted with status: ' + response.statusCode);
    helpers.respondStatus(res, response.statusCode);
  });
});

// Add new item to cart
app.post("/cart", function (req, res, next) {
  console.log("Attempting to add to cart: " + JSON.stringify(req.body));

  if (req.body.id == null) {
    next(new Error("Must pass id of item to add"), 400);
    return;
  }

  var custId = helpers.getCustomerId(req, env);

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
    helpers.respondStatus(res, statusCode);
  });
});

//Orders
app.get("/orders", function (req, res, next) {
  console.log("Request received with body: " + JSON.stringify(req.body));
  // var custId = helpers.getCustomerId(req, env);
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
    helpers.respondStatusBody(res, 201, JSON.stringify(result));
  });
});

app.get("/orders/*", function (req, res, next) {
  var url = ordersUrl + req.url.toString();
  request.get(url).pipe(res);
});

app.post("/orders", function(req, res, next) {
  console.log("Request received with body: " + JSON.stringify(req.body));
  // var custId = helpers.getCustomerId(req, env);
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
    helpers.respondStatusBody(res, status, JSON.stringify(result));
  });
});

var server = app.listen(process.env.PORT || 8079, function () {
  var port = server.address().port;
  console.log("App now running in %s mode on port %d", env, port);
});
