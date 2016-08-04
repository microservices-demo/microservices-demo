(function (){
  'use strict';
  require("./config");

  var TESTS = 2;

  casper.test.begin("User interacts with the catalogue", TESTS, function(test) {
    casper.start("http://localhost:8080/", function() {
      this.clickLabel("Catalogue");
    });

    casper.then(function() {
      test.assertTextExists("Showing 6 of 9 products", "pagination text matches number of shown socks pairs");
      test.assertElementCount("#products .product", 6, "user is presented with 6 pairs of socks");
    });

    casper.run(function() {
      test.done();
    });
  });
}());
