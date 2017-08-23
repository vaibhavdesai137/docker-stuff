var http = require('http');

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end('<h1>Howdy from NodeJS running as docker!!!<h1>');
}).listen(9080);