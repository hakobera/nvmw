var http = require('http'),
    url = require('url'),
    fs = require('fs');

function wget(uri, callback) {
    console.log('Download file from %s', uri);

    var options = url.parse(uri);
    var paths = options.pathname.split('/');
    var filename = paths[paths.length - 1];
    console.log(filename);

    var req = http.get(options, function (res) {
        var contentLength = parseInt(res.headers['content-length'], 10);
        console.log('Content length is %d', contentLength);

        var data = new Buffer(contentLength);
        var offset = 0;

        res.on('data', function (chunk) {
            var buf = new Buffer(chunk);
            console.log('Download %d bytes ...', offset);
            buf.copy(data, offset);
            offset += buf.length;
        });

        res.on('end', function () {
            console.log('Donwload done');
            callback(filename, data);
        });
    });

    req.on('error', function (e) {
        console.log('Got error: ' + e.message);
    });
}

module.exports = wget;