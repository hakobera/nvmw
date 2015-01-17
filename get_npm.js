var util = require('util'),
    fs = require('fs'),
    path = require('path'),
    wget = require('./wget');

var NPM_PKG_JSON_URL = 'https://raw.githubusercontent.com/%s/%s/deps/npm/package.json';
// https://github.com/npm/npm/tags
var NVMW_NPM_MIRROR = process.env.NVMW_NPM_MIRROR || 'https://github.com/npm/npm/archive';
var BASE_URL = NVMW_NPM_MIRROR + '/v%s.zip';

var targetDir = process.argv[2];
var versions = process.argv[3].split('/');
var binType = versions[0];
var binVersion = versions[1];

var pkgUri;
if (binType === 'iojs') {
  pkgUri = util.format(NPM_PKG_JSON_URL, 'iojs/io.js', binVersion + '-release');
} else {
  pkgUri = util.format(NPM_PKG_JSON_URL, 'joyent/node', binVersion);
}

wget(pkgUri, function (filename, pkg) {
    if (filename === null) {
        console.error('%s %s does not include npm', binType, binVersion);
        process.exit(1);
    }
    var npmVersion = JSON.parse(pkg).version;
    var uri = util.format(BASE_URL, npmVersion);
    wget(uri, function (filename, data) {
        fs.writeFile(path.join(targetDir, 'npm.zip'), data, function (err) {
            if (err) {
                return console.log(err.message);
            }
            console.log('Download npm %s is done', npmVersion);
        });
    });
});
