var request = require('request');
var express = require('express');
var path = require("path");
var bodyParser = require("body-parser");

var app = express();
app.use(express.static(__dirname + "/"));
app.use(bodyParser.json());

var catalogueUrl = "http://catalogue/catalogue";
var accountsUrl = "http://accounts/accounts";
var cartsUrl = "http://carts/carts/search/findByCustomerId";

function handleError(res, reason, message, code) {
	console.log("Error: " + reason);
	res.status(code || 500).json({"error": message});
}

// Catalogue
app.get("/catalogue", function(req, res) {
	if (app.get('env') == "development") {
		catalogueUrl = "http://localhost:8081/catalogue";
	}

	request(catalogueUrl, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  }
	}.bind( {res: res} ));
});

app.get("/catalogue/:id", function(req, res) {
	if (app.get('env') == "development") {
		catalogueUrl = "http://localhost:8081/catalogue";
	}

	request(catalogueUrl + "/" + req.params.id, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  }
	}.bind( {res: res} ));
});

// Accounts
app.get("/accounts/", function(req, res) {
	if (app.get('env') == "development") {
		accountsUrl = "http://localhost:8082/accounts";
	}

	request(accountsUrl + "?custId=fakeId", function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  }
	}.bind( {res: res} ));
});

app.get("/accounts/:id", function(req, res) {
	if (app.get('env') == "development") {
		accountsUrl = "http://localhost:8082/accounts";
	}

	request(accountsUrl + "/" + req.params.id, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  }
	}.bind( {res: res} ));
});

//Carts
app.get("/carts/", function(req, res) {
	if (app.get('env') == "development") {
		cartsUrl = "http://localhost:8083/carts/search/findByCustomerId";
	}

	request(accountsUrl + "?custId=fakeId", function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  }
	}.bind( {res: res} ));
});

var server = app.listen(process.env.PORT || 8079, function () {
	var port = server.address().port;
	console.log("App now running on port", port);
});