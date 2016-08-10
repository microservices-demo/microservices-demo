var request      = require("request")
  , express      = require("express")
  , path         = require("path")
  , bodyParser   = require("body-parser")
  , async        = require("async")
  , cookieParser = require("cookie-parser")
  , session      = require("express-session")
  , config       = require("./config")
  , helpers      = require("./helpers")
  , login        = require("./api/login")
  , cart         = require("./api/cart")
  , accounts     = require("./api/accounts")
  , catalogue    = require("./api/catalogue")
  , orders       = require("./api/orders")
  , app          = express()

app.use(session(config.session));
app.use(express.static(__dirname + "/"));
app.use(bodyParser.json());
app.use(cookieParser());
app.use(helpers.errorHandler);

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

/* Mount API endpoints */
app.use(login);
app.use(cart);
app.use(accounts);
app.use(catalogue);
app.use(orders);

var server = app.listen(process.env.PORT || 8079, function () {
  var port = server.address().port;
  console.log("App now running in %s mode on port %d", app.get("env"), port);
});
