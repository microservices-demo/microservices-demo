(function (){
  'use strict';

  var express   = require("express")
    , request   = require("request")
    , endpoints = require("../endpoints")
    , helpers   = require("../../helpers")
    , app       = express()

  // Register - TO BE USED FOR TESTING ONLY (for now)
  app.get("/register", function(req, res, next) {
    helpers.simpleHttpRequest(registerUrl + "?username=" + req.query.username + "&password=" + req.query.password, res, next);
  });

  app.get("/accounts/:id", function (req, res, next) {
    helpers.simpleHttpRequest(endpoints.customersUrl + "/" + req.params.id, res, next);
  });

  // Create Customer - TO BE USED FOR TESTING ONLY (for now)
  app.post("/customers", function(req, res, next) {
    var options = {
      uri: endpoints.customersUrl,
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
      uri: endpoints.addressUrl,
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
      uri: endpoints.cardsUrl,
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
      uri: endpoints.customersUrl + "/" + req.params.id,
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
      uri: endpoints.addressUrl + "/" + req.params.id,
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
      uri: endpoints.cardsUrl + "/" + req.params.id,
      method: 'DELETE'
    };
    request(options, function (error, response, body) {
      if (error) {
        return next(error);
      }
      helpers.respondSuccessBody(res, JSON.stringify(body));
    }.bind({res: res}));
  });

  module.exports = app;
}());
