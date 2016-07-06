# cordova-music-remote-controls


## Supported platforms
- Android 
- iOS

## Methods
- Create the media controls:
```javascript

  function remoteCommandCallback(event,value){
          switch(event){
              case MusicControls.EVENT_PLAY:
                  console.log("######### remoteCommandCallback, event: PLAY");
                  //"value" is zero for this event
                  break;
              case MusicControls.EVENT_PAUSE:
                  console.log("######### remoteCommandCallback, event: PAUSE");
                  //"value" is zero for this event
                  break;
              case MusicControls.EVENT_TOGGLE_PLAY_PAUSE:
                  console.log("######### remoteCommandCallback, event: TOGGLE PLAY PAUSE");
                  //"value" is zero for this event
                  break;
              case MusicControls.EVENT_SKIP_FORWARD:
                  console.log("######### remoteCommandCallback, event: SKIP FW");
                  //"value" is the amout of seconds to skip (the value in info.skipForwardValue)
                  break;
              case MusicControls.EVENT_SKIP_BACKWARD:
                  console.log("######### remoteCommandCallback, event: SKIP BW");
                  //"value" is the amout of seconds to skip (the value in info.skipBackwardValue)
                  break;
          }//switch
      }


var info = {
	title       	: 'Title',		// optional, default : ''
	artist      	: 'Artist',		// optional, default : ''
	artwork	: 'albums/cover.jpg',		// optional, default : nothing
	// cover can be a local path (use fullpath 'file:///storage/emulated/...', or only 'my_image.jpg' if my_image.jpg is in the www folder of your app) or a remote url ('http://...', 'https://...', 'ftp://...')
	isPlaying	: true,			// optional, default : true  [Android]
	dismissable	: true,			// optional, default : false [Android]
	
	// hide previous/next/close buttons:
	hasPrev   	: false,		// show previous button, optional, default: true [Android]
	hasNext   	: false,		// show next button, optional, default: true [Android]
	hasClose  	: true,			// show close button, optional, default: false [Android]

	// Android only, optional
	// text displayed in the status bar when the notification (and the ticker) are updated
	ticker	  : 'Now playing "Time is Running Out"' [Android]
	
	// iOS only
	albumTrackCount   :10, 			// [iOS]
	albumTrackNumber  :1, 			// [iOS]
	playbackDuration  :234.76, 		//in seconds [iOS]
	playbackPosition  :12.5, 		//in seconds, usually this is zero // [iOS]
	playbackRate      :1.0, 		// [iOS]
  
  	/* [iOS] these are used for the skip FW & BW events. It these are missing, the events are not handled and the skip buttons will not be shown in the lock screen.*/
  	skipForwardValue	:30,
  	skipBackwardValue	:30
	
};

var mControl = new MusicControls(info,remoteCommandCallback);

// Register callback for android
mControl.subscribe(remoteCommandCallback);

// Start listening for events
// The plugin will run the events function each time an event is fired
mControl.listen();

```

- Destroy the media controller:
```javascript
mControl.destroy(clearInfo);
```
- Methods:

```javascript
updateIsPlaying(true): Toggle the play/pause notification button [Android]

updateInfo(info): Updates the information shown in the lock screen.

updatePlaybackRate(newPlaybackRate): Updates (only) the playback rate. Uses updateInfo internally [iOS].

updatePlaybackPosition(newPlaybackPosition): Updates (only) the playback position. Uses updateInfo internally [iOS].
```
