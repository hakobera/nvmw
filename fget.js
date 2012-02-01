main(WScript.Arguments);

/**
 * Main function
 * @param {Object} args Command line arguments
 */
function main(args) {
  if (args.length < 2) {
    log('useage: CScript fget.js [url] [filname]');
    WScript.Quit(1);
  }

  var url = args(0)
    , filename = args(1);

  var completed = false;
  downloadFile(url, filename, function(err) {
    if (err) {
      log(err.message);
    } else {
      log('Done');
    }
    completed = true;
  });

  while (!completed) {
    WScript.Sleep(1000);
  }
}

/**
 * Log output to console.
 * @param {String} message
 */
function log(message) {
  WScript.Echo(message);
}

/**
 * Download file from specified URL
 *
 * @param {String} url Url to download
 * @param {String} filename Filename to save
 * @param {Function} callback Callback function when download is completed or failed
 */
function downloadFile(url, filename, callback) {
  var xhr = WScript.createObject('Msxml2.XMLHTTP')
    , ostream = new ActiveXObject("Adodb.Stream");

  log('Download from ' + url + ', and save it as ' + filename);

  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        ostream.type = 1/*adTypeBinary*/;
        ostream.open();
        ostream.write(xhr.responseBody);
        ostream.savetofile(filename, 2/* adSaveCreateOverWrite */);
        callback();
      } else {
        callback(new Error(xhr.status + ' ' + xhr.statusText));
      }
      xhr = null;
      ostream = null;
    }
  }

  try {
    xhr.open('GET', url, true);
    xhr.send(null);
  } catch (e) {
    callback(new Error('URL may be invalid'));
    xhr.abort();
  }
}
