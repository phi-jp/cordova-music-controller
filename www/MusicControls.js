module.exports = {
  updateCallback: function () {},

  create: function (data, successCallback, errorCallback) {
    if (data.artist === undefined) {
      data.artist = '';
    }
    if (data.title === undefined) {
      data.title = '';
    }
    if (data.artwork === undefined) {
      data.artwork = '';
    }
    if (data.ticker === undefined) {
      data.ticker = '';
    }
    if (data.isPlaying === undefined) {
      data.isPlaying = true;
    }
    if (data.hasPrev === undefined) {
      data.hasPrev = true;
    }
    if (data.hasNext === undefined) {
      data.hasNext = true;
    }
    if (data.hasClose === undefined) {
      data.hasClose = false;
    }
    if (data.dismissable === undefined) {
      data.dismissable = false;
    }

    cordova.exec(successCallback, errorCallback, 'MusicControls', 'create', [data]);
  },

  updateIsPlaying: function (isPlaying, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, 'MusicControls', 'updateIsPlaying', [{isPlaying: isPlaying}]);
  },

  updateInfo: function(info) {
    cordova.exec(successCallback, errorCallback, "MusicControls", "updateInfo", [info]);
  },

  updatePlaybackRate: function(rate) {
    cordova.exec(successCallback, errorCallback, "MusicControls", "updateInfo", [{'playbackRate':rate}]);
  },

  updatePlaybackPosition: function(pos) {
    cordova.exec(successCallback, errorCallback, "MusicControls", "updateInfo", [{'playbackPosition':pos}]);
  },

  destroy: function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, 'MusicControls', 'destroy', []);
  },

  // Register callback
  subscribe: function (onUpdate) {
    module.exports.updateCallback = onUpdate;
  },
  // Start listening for events
  listen: function () {
    cordova.exec(module.exports.receiveCallbackFromNative, function (res) {
    }, 'MusicControls', 'watch', []);
  },
  receiveCallbackFromNative: function (messageFromNative) {
    module.exports.updateCallback(messageFromNative);
    cordova.exec(module.exports.receiveCallbackFromNative, function (res) {
    }, 'MusicControls', 'watch', []);
  }

};
