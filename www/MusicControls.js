/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var musicControlObject = null;

/**
 * This class provides access to the device media, interfaces to both sound and video
 *
 * @constructor
 * @param src                   The file name or url to play
 * @param successCallback       The callback to be called when the file is done playing or recording.
 *                                  successCallback()
 * @param errorCallback         The callback to be called if there is an error.
 *                                  errorCallback(int errorCode) - OPTIONAL
 * @param statusCallback        The callback to be called when media status has changed.
 *                                  statusCallback(int statusCode) - OPTIONAL
 */
var MusicControls = function(eventsAndInfo, eventCallback) {
    //argscheck.checkArgs('sFFF', 'Media', arguments);
	if(musicControlObject){
		exec(null, null, "MusicControls", "destroy", []);
		delete musicControlObject;
	}
    musicControlObject = this;
    this.eventsAndInfo = eventsAndInfo;
    this.eventCallback = eventCallback;
    exec(null, null, "MusicControls", "create", [eventsAndInfo]);
};

MusicControls.prototype.release = function(clearInfo) {
	var clearInfoNr;
	if(typeof(clearInfo)!=='undefined' && clearInfo)clearInfoNr=1;
	else clearInfoNr=0;
    exec(null, null, "MusicControls", "destroy", [clearInfoNr]);
    delete musicControlObject;
    musicControlObject=null;
};

MusicControls.prototype.updateInfo = function(info) {
    exec(null, null, "MusicControls", "updateInfo", [info]);
};

//easier-to-use functions
MusicControls.prototype.updatePlaybackRate = function(rate) {
    exec(null, null, "MusicControls", "updateInfo", [{'playbackRate':rate}]);
};
MusicControls.prototype.updatePlaybackPosition = function(pos) {
    exec(null, null, "MusicControls", "updateInfo", [{'playbackPosition':pos}]);
};

// Register callback
MusicControls.prototype.subscribe = function (eventType) {
  if(!musicControlObject)return;
  if(typeof(musicControlObject.eventCallback)!=='function')return;

	musicControlObject.eventCallback(eventType);
};

// Start listening for events
MusicControls.prototype.listen = function () {
  cordova.exec(musicControlObject.receiveCallbackFromNative, function (res) {
  }, 'MusicControls', 'watch', []);
};

MusicControls.prototype.receiveCallbackFromNative = function (messageFromNative) {
  musicControlObject.eventCallback(messageFromNative);
  cordova.exec(musicControlObject.receiveCallbackFromNative, function (res) {
  }, 'MusicControls', 'watch', []);
};


MusicControls.EVENT_PLAY = "music-controller-play";
MusicControls.EVENT_PAUSE = 'music-controller-pause';
MusicControls.EVENT_TOGGLE_PLAY_PAUSE = 'music-controller-play-pause';

MusicControls.EVENT_SKIP_FORWARD = 'music-controller-next';
MusicControls.EVENT_SKIP_BACKWARD = 'music-controller-previous';


MusicControls.onEvent = function(eventType, value) {
	if(!musicControlObject)return;
	if(typeof(musicControlObject.eventCallback)!=='function')return;

	musicControlObject.eventCallback(eventType,value);
};

module.exports = MusicControls;

function onMessageFromNative(msg) {
    if (msg.action == 'event') {
        MusicControls.onEvent(msg.event.type, msg.event.value);
    } else {
        throw new Error('Unknown MusicControls action' + msg.action);
    }
}


/*
if (cordova.platformId === 'android' || cordova.platformId === 'amazon-fireos' || cordova.platformId === 'windowsphone') {

    var channel = require('cordova/channel');

    channel.createSticky('onMediaPluginReady');
    channel.waitForInitialization('onMediaPluginReady');

    channel.onCordovaReady.subscribe(function() {
        exec(onMessageFromNative, undefined, 'Media', 'messageChannel', []);
        channel.initializationComplete('onMediaPluginReady');
    });
}*/
