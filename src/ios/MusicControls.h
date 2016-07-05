/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

@import MediaPlayer;
@import Foundation;

#import <Cordova/CDVPlugin.h>

/*
enum CDVMediaStates {
    MEDIA_NONE = 0,
    MEDIA_STARTING = 1,
    MEDIA_RUNNING = 2,
    MEDIA_PAUSED = 3,
    MEDIA_STOPPED = 4
};
typedef NSUInteger CDVMediaStates;

enum CDVMediaMsg {
    MEDIA_STATE = 1,
    MEDIA_DURATION = 2,
    MEDIA_POSITION = 3,
    MEDIA_ERROR = 9
};
typedef NSUInteger CDVMediaMsg;

 */



@interface MusicControls : CDVPlugin

- (NSURL*)urlForArtwork:(NSString*)resourcePath;
- (void)release:(CDVInvokedUrlCommand*)command;
- (void)updateInfo:(CDVInvokedUrlCommand*)command;

//events
- (void) playEvent:(MPRemoteCommandEvent*)event;
- (void) pauseEvent:(MPRemoteCommandEvent*)event;
- (void) playOrPauseEvent:(MPRemoteCommandEvent*)event;

- (void) skipForwardEvent: (MPSkipIntervalCommandEvent*)event;
- (void) skipBackwardEvent:(MPSkipIntervalCommandEvent*)event;

@end
