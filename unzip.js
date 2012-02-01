main(WScript.Arguments);

/**
 * Main function
 * @param {Object} args Command line arguments
 */
function main(args) {
  if (args.length < 2) {
    log('useage: CScript unzip.js [zipfile] [output]');
    WScript.Quit(1);
  }

  var zipfile = args(0),
      outPath = args(1);

  var shell = new ActiveXObject("shell.application");
  var zip = shell.NameSpace(zipfile);
  var out = shell.NameSpace(outPath);
  out.CopyHere(zip.Items(), 0);
 
  shell = null; 
}
