var http = require('http');
var finalhandler = require('finalhandler');
var serveStatic = require('serve-static');
var request = require('request');

const PORT=8079;
// var catalogueUrl = "http://192.168.99.100:8081/catalogue";
var catalogueUrl = "http://catalogue:8081/catalogue";
// var catalogueUrl = "http://localhost:8081/catalogue";

var serve = serveStatic("./");

function handleRequest(req, res) {
	console.log('request: ' + req.url)
	if (req.url.indexOf('/getData') > -1) {
		console.log('get data');
		request(catalogueUrl, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
			res.writeHeader(200);
			res.write(body);
			res.end()
		  }
		}.bind( {res: res} ));


	} else {
		if (req.url == '/') {
			req.url = '/index.html';
		}
		var done = finalhandler(req, res);
  		serve(req, res, done);
	}
}

var server = http.createServer(handleRequest);

server.listen(PORT, function(){
	console.log("Server running on port: %s", PORT);
});