process.title = 'MyWebServer';
var args = process.argv,
port = args[2] || 7070,
webServer = require('./server');

webServer.listen(port, function() {
    console.log('Server started at port ' + port);
});

fs = require('fs')
fs.watch('./src/pecas', { encoding: 'buffer' }, (eventType, filename) => {
  if (filename) {
    console.log(filename);
    // Prints: <Buffer ...>
  }
});

//fs = require('fs')
//fs.readFile('/srs/pecas', 'ascii', function (err,data) {
//  if (err) {
//    return console.log(err);
//  }
//  console.log(data);
//});