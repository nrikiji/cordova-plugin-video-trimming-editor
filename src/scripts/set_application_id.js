#!/usr/bin/env node

var exec = require("child_process").exec
var execSync = require("child_process").execSync
var fs = require("fs")
var path = require("path")

var stdio = { stdio:[0, 1, 2] };

module.exports = function (context) {
  var rootPath = context.opts.projectRoot;
  var configPath = path.join(rootPath, "config.xml");
  var configParser = getConfigParser(context, configPath);
  var platformPath = rootPath + "/platforms/android";
  var pluginPath = platformPath + "/app/src/main/java/plugin/videotrimmingeditor";

  var applicationId = configParser.packageName();

  var sourcePath = pluginPath + "/features/trim/VideoTrimmerActivity.java";
  var source = fs.readFileSync(sourcePath, 'utf-8')
  fs.writeFileSync(sourcePath, source.replace('#{APPLICATION_ID}', configParser.packageName()));

  sourcePath = pluginPath + "/utils/StorageUtil.java";
  source = fs.readFileSync(sourcePath, 'utf-8')
  fs.writeFileSync(sourcePath, source.replace('#{APPLICATION_ID}', configParser.packageName()));

  function getConfigParser(context, config) {
    let ConfigParser = context.requireCordovaModule('cordova-common/src/ConfigParser/ConfigParser');
    return new ConfigParser(configPath);
  }
}
