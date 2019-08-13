'use strict';

var exec = require('cordova/exec');

var VideoTrimmingEditor = {

  open: function(param, onSuccess, onFail) {
    return exec(onSuccess, onFail, 'VideoTrimmingEditor', 'open', [param]);
  }
};
module.exports = VideoTrimmingEditor;
