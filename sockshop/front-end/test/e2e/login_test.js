(function (){
  'use strict';

  require("./config");

  casper.test.begin("User logs in", 3, function suite(test) {
    casper.start("http://localhost:8080/", function() {
      test.assertNotVisible("#login-modal", "user does not see the login dialogue");

      this.clickLabel("Login");
      casper.waitUntilVisible("#login-modal", function() {
        test.assertVisible("#login-modal", "user is presented with the login dialogue");
        this.fill("#login-modal form", {
          "username": "Eve_Berger",
          "password": "duis"
        }, false);
      }, function() {
        test.fail("login dialogue never showed up");
      }, 1000);
    });

    casper.then(function() {
      this.click("#login-modal form button.btn.btn-primary");
      this.wait(1000, function() {
        test.assertTextExists("Logged in as Eve Berger", "user is logged in");
      });
    });

    casper.run(function() {
      test.done();
    });
  });
}());
