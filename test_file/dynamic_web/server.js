var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.write("IN");
  response.write(" | ");
  response.write(process.env.HOSTNAME);
  response.end(": Hello World!  |v2| \n");
};
var www = http.createServer(handleRequest);
www.listen(8080);
