var util = require('util'),
    fs = require('fs'),
    path = require('path'),
    wget = require('./wget'),
    npmVersions = require('./npm');

var BASE_URL = 'http://nodejs.org/dist/npm/npm-%s.zip';

var targetDir = process.argv[2];
var nodeVersion = process.argv[3];
var npmVersion = npmVersions[nodeVersion];

if (!npmVersion) {
  console.error('Node %s is not supported', nodeVersion);
  process.exit(1);
} else {
  var uri = util.format(BASE_URL, npmVersion);
  wget(uri, function (filename, data) {
    fs.writeFile(path.join(targetDir, 'npm.zip'), data, function (err) {
      if (err) {
        return console.log(err.message);
      }
      console.log('Download npm %s is done', npmVersion);
    });
  });
}
