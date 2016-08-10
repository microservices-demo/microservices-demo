(function (){
  'use strict';

  var request = require("request");
  var helpers = {};

  helpers.errorHandler = function(err, req, res, next) {
    console.error(err.stack);
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  };

  /* Responds with the given body and status 200 OK  */
  helpers.respondSuccessBody = function(res, body) {
    helpers.respondStatusBody(res, 200, body);
  }

  /* Reponds with the given body and status */
  helpers.respondStatusBody = function(res, statusCode, body) {
    res.writeHeader(statusCode);
    res.write(body);
    res.end();
  }

  /* Responds with the given statusCode */
  helpers.respondStatus = function(res, statusCode) {
    res.writeHeader(statusCode);
    res.end();
  }

  /* Performs an HTTP GET request to the given URL */
  helpers.simpleHttpRequest = function(url, res, next) {
    var that = this;
    console.log("GET " + url);
    request.get(url, function (error, response, body) {
      if (error) {
        return next(error);
      }
      helpers.respondSuccessBody(res, body);
    }.bind({res: res}));
  }

  /* TODO: Add documentation */
  helpers.getCustomerId = function(req, env) {
    // Check if logged in. Get customer Id
    var custId = req.cookies.logged_in;

    // TODO REMOVE THIS, SECURITY RISK
    if (env == "development" && req.query.custId != null) {
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
  module.exports = helpers;
}());
