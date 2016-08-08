(function (){
  'use strict';
  require("./config");

  var __utils__ = require("clientutils").create();
  var TESTS = 6;

  casper.test.begin("User buys some socks", TESTS, function(test) {
    // initial load and login
    casper.start("http://localhost:8080/", function() {
      this.clickLabel("Login");
      this.fill("#login-modal form", {
        "username": "Eve_Berger",
        "password": "duis"
      }, true);
      this.click("#login-modal form button.btn.btn-primary");
      this.waitForText("Logged in", function() {
        test.comment("user logged in");
      }, function() {
        test.fail("login failed");
      }, 1000);
    });

    // TODO: Test that "Proceed to checkout" button is disabled when the cart is empty

    // access the catalogue
    casper.then(function() {
      this.clickLabel("Catalogue");
      test.comment("accessing the catalogue");
    });

    // add some items to the cart
    casper.then(function() {
      this.clickLabel("Add to cart");
    });

    // go to the shopping cart
    casper.then(function() {
      this.waitForText("1 item(s) in cart", function() {
        test.pass("cart is updated with one product");
        this.clickLabel("1 item(s) in cart");
      }, function() {
        test.fail("cart was not updated");
      }, 1000);
    });

    casper.then(function() {
      test.assertTextExists("Shopping cart", "user is taken to the shopping cart overview");
      test.assertTextExists("Proceed to checkout", "user is presented with the checkout button");

      // The checkout button is disabled by default on page load. It will only get enabled
      // once the cart has been loaded (asynchronously). Hence the waiting.
      casper.waitFor(function() {
        return this.evaluate(function() {
          var b = __utils__.findOne("button#orderButton");
          if (b) return b.getAttribute("disabled") == undefined; // wait until the "disabled" attribute has been removed means that the button is now enabled
          return false;
        });
      }, function() {
        test.pass("the checkout button is enabled");
      }, function() {
        test.fail("checkout button was not enabled");
      }, 1000);
    });

    casper.then(function() {
      this.click("button#orderButton");
    });

    // actually checkout
    casper.then(function() {
      this.waitForText("My orders", function() {
        test.pass("user is taken to the orders page");
        test.assertTextExists("0 items in cart", "cart gets emptied");
      }, function() {
        casper.capture("cart.png");
        test.fail("user was not taken to the orders page");
      }, 2000);
    });

    casper.run(function() {
      test.done();
    });
  });
}());
