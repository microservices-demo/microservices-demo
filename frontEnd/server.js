var request = require('request');
var express = require('express');
var path = require("path");
var bodyParser = require("body-parser");

var app = express();
app.use(express.static(__dirname + "/"));
app.use(bodyParser.json());

var catalogueUrl = "http://catalogue:8081/catalogue";

function handleError(res, reason, message, code) {
	console.log("Error: " + reason);
	res.status(code || 500).json({"error": message});
}

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

var server = app.listen(process.env.PORT || 8079, function () {
	var port = server.address().port;
	console.log("App now running on port", port);
});