(function (){
  'use strict';

  var express = require("express");
  var http = require("http");
  var request = require("supertest");
  var expect = require("chai").expect;
  var helpers = require("../helpers");

  var app = express();

  describe("helpers", function() {
    describe("#respondSuccessBody", function() {
      it("renders the given body with status 200 OK", function(done) {
        var app = express();

        app.use(function(req, res) {
          helpers.respondStatusBody(res, 200, "ayylmao");
        });

        request(app).
          get("/").
          expect(200, "ayylmao", done);
      });
    });

    describe("#respondStatusBody", function() {
      it("sets the proper status code & body", function(done) {
        var app = express();

        app.use(function(req, res) {
          helpers.respondStatusBody(res, 201, "foo");
        });

        request(app).
          get("/").
          expect(201, "foo", done);
      });
    });

    describe("#respondStatus", function() {
      it("sets the proper status code", function(done) {
        var app = express();

        app.use(function(req, res) {
          helpers.respondStatusBody(res, 404, "");
        });

        request(app).
          get("/").
          expect(404, "", done);
      });
    });

    describe("#simpleHttpRequest", function() {
      it("performs a GET request to the given URL");
    });

    describe("#getCustomerId", function() {
      describe("given the environment is development", function() {
        it("returns the customer id from the query string");
      });

      describe("given a customer id set in session", function() {
        it("returns the customer id from the session");
      });

      describe("given no customer id set in the cookies", function() {
        describe("given no customer id set session", function() {
          it("throws a 'User not logged in' error");
        });
      });
    });
  });
 }());
