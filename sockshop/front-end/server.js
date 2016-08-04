var request      = require("request")
  , express      = require("express")
  , path         = require("path")
  , bodyParser   = require("body-parser")
  , async        = require("async")
  , cookieParser = require("cookie-parser")
  , session      = require("express-session")
  , helpers      = require("./helpers")
  , login        = require("./api/login")
  , cart         = require("./api/cart")
  , accounts     = require("./api/accounts")
  , catalogue    = require("./api/catalogue")
  , orders       = require("./api/orders")

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
