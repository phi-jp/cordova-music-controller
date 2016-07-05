# cordova-music-remote-controls


## Supported platforms
- Android 
- iOS

## Methods
- Create the media controls:
```javascript
MusicControls.create({
    title       : 'Title',		// optional, default : ''
	  artist      : 'Artist',						// optional, default : ''
    artwork       : 'albums/cover.jpg',		// optional, default : nothing
	// cover can be a local path (use fullpath 'file:///storage/emulated/...', or only 'my_image.jpg' if my_image.jpg is in the www folder of your app)
	//			 or a remote url ('http://...', 'https://...', 'ftp://...')
    isPlaying   : true,							// optional, default : true  [Android]
	  dismissable : true,							// optional, default : false [Android]

	// hide previous/next/close buttons:
	hasPrev   : false,		// show previous button, optional, default: true [Android]
	hasNext   : false,		// show next button, optional, default: true [Android]
	hasClose  : true,		// show close button, optional, default: false [Android]

	// Android only, optional
	// text displayed in the status bar when the notification (and the ticker) are updated
	ticker	  : 'Now playing "Time is Running Out"' [Android]
	
	// iOS only
	albumTrackCount   :10, // [iOS]
  albumTrackNumber  :1, // [iOS]
  playbackDuration  :234.76, //in seconds [iOS]
  playbackPosition  :12.5, //in seconds, usually this is zero // [iOS]
  playbackRate      :1.0, // [iOS]
  
  /* [iOS] these are used for the skip FW & BW events. It these are missing, the events are not handled and the skip buttons will not be shown in the lock screen.*/
  skipForwardValue:30,
  skipBackwardValue:30
	
}, onSuccess, onError);
```

- Destroy the media controller:
```javascript
MusicControls.destroy(onSuccess, onError);
```

- Subscribe events to the media controller:
```javascript
function events(action) {
	switch(action) {
		case 'music-controls-next':
			// Do something
			break;
		case 'music-controls-previous':
			// Do something
			break;
		case 'music-controls-pause':
			// Do something
			break;
		case 'music-controls-play-or-pause':
			// Do something [iOS]
			break;
		case 'music-controls-play':
			// Do something
			break;
		case 'music-controls-destroy':
			// Do something
			break;
		default:
			break;
	}
}

// Register callback
MusicControls.subscribe(events);

// Start listening for events
// The plugin will run the events function each time an event is fired
MusicControls.listen();
```

- Toggle play/pause:
```javascript
MusicControls.updateIsPlaying(true); // toggle the play/pause notification button [Android]

MusicControls.updateInfo(info): Updates the information shown in the lock screen.

MusicControls.updatePlaybackRate(newPlaybackRate): Updates (only) the playback rate. Uses updateInfo internally [iOS].

MusicControls.updatePlaybackPosition(newPlaybackPosition): Updates (only) the playback position. Uses updateInfo internally [iOS].
```
