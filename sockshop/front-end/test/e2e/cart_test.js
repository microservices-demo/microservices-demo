(function (){
  'use strict';
  require("./config");

  var TESTS = 1;

  casper.test.begin("User interacts with the cart", TESTS, function(test) {
    // initial load and login
    casper.start("http://localhost:8080/", function() {
      this.clickLabel("Login");
      this.fill("#login-modal form", {
        "username": "Eve_Berger",
        "password": "duis"
      }, true);
      this.click("#login-modal form button.btn.btn-primary");
      this.waitForText("Logged in", function() {
        // then
      }, function() {
        test.fail("login failed");
      }, 1000);
    });

    // access the catalogue
    casper.then(function() {
      this.clickLabel("Catalogue");
    });

    // Add some items to the cart and verify
    casper.then(function() {
      this.clickLabel("Add to cart");
      this.waitForText("1 item(s) in cart", function() {
        test.pass("cart gets updated with user selection");
      }, function() {
        test.fail("cart was not updated");
        // timeout
      }, 1000);
    });


    casper.run(function() {
      test.done();
    });
  });
}());
