var url = require('url'),
    bytes = require('./bytes'),
    fs = require('fs');

function wget(uri, callback) {
    console.log('Download file from %s', uri);

    var options = url.parse(uri);
    var paths = options.pathname.split('/');
    var filename = paths[paths.length - 1];
    console.log(filename);

    var http = require(uri.indexOf('https') === 0 ? 'https' : 'http');

    var req = http.get(options, function (res) {
        if (res.statusCode === 302 || res.statusCode === 301) {
            return wget(res.headers.location, callback);
        }
        if (res.statusCode !== 200) {
            callback(null);
            return;
        }
        var contentLength = parseInt(res.headers['content-length'], 10);
        console.log('Content length is %s', bytes(contentLength));

        var data = new Buffer(contentLength);
        var offset = 0;

        var start = Date.now();
        res.on('data', function (buf) {
            buf.copy(data, offset);
            offset += buf.length;
            var use = Date.now() - start;
            if (use === 0) {
              use = 1;
            }
            console.log('Download %d%, %s / %s, %s/s ...',
                parseInt(offset / contentLength * 100, 10), bytes(offset), bytes(contentLength),
                bytes(offset / use * 1000));
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
