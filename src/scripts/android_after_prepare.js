#!/usr/bin/env node

var fs = require("fs")
var path = require("path")

module.exports = function(context) {

  var platformRoot = path.join(context.opts.projectRoot, 'platforms/android/app/src/main');
  var manifestFile = path.join(platformRoot, 'AndroidManifest.xml');

  console.log('############### Start');
  console.log(manifestFile);

  if (fs.existsSync(manifestFile)) {

    fs.readFile(manifestFile, 'utf8', function (err,data) {

      console.log(err);
      console.log(data);
      
      if (err) {
        throw new Error('Unable to find AndroidManifest.xml: ' + err);
      }

      var appClass = 'plugin.videotrimmingeditor.ZApplication';
      if (data.indexOf(appClass) == -1) {
        var result = data.replace(/<application/g, '<application android:name="' + appClass + '"');
        fs.writeFile(manifestFile, result, 'utf8', function (err) {
          if (err) throw new Error('Unable to write into AndroidManifest.xml: ' + err);
        })
      }
    });
  }
};
