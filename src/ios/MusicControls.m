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

#import "CDVFile.h"
#import "MusicControls.h"

#define DOCUMENTS_SCHEME_PREFIX @"documents://"
#define CDVFILE_PREFIX @"cdvfile://"

@implementation MusicControls

NSMutableDictionary *newInfo;

- (MPMediaItemArtwork *) urlForArtwork: (NSString *) resourcePath
{
    UIImage * coverImage = nil;
    NSURL* resourceURL = nil;
    NSString* filePath = nil;

    // first try to find HTTP:// or Documents:// resources

    if ([resourcePath hasPrefix:DOCUMENTS_SCHEME_PREFIX]) {
        NSString* docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        filePath = [resourcePath stringByReplacingOccurrencesOfString:DOCUMENTS_SCHEME_PREFIX withString:[NSString stringWithFormat:@"%@/", docsPath]];
        NSLog(@"Will use resource '%@' from the documents folder with path = %@", resourcePath, filePath);
    } else if ([resourcePath hasPrefix:CDVFILE_PREFIX]) {
        CDVFile *filePlugin = [self.commandDelegate getCommandInstance:@"File"];
        CDVFilesystemURL *url = [CDVFilesystemURL fileSystemURLWithString:resourcePath];
        filePath = [filePlugin filesystemPathForURL:url];
        if (filePath == nil) {
            resourceURL = [NSURL URLWithString:resourcePath];
        }
    } else {
        // attempt to find file path in www directory or LocalFileSystem.TEMPORARY directory
        filePath = [self.commandDelegate pathForResource:resourcePath];
        if (filePath == nil) {
            // see if this exists in the documents/temp directory from a previous recording
            NSString* testPath = [NSString stringWithFormat:@"%@/%@", [NSTemporaryDirectory()stringByStandardizingPath], resourcePath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:testPath]) {
                // inefficient as existence will be checked again below but only way to determine if file exists from previous recording
                filePath = testPath;
                NSLog(@"Will attempt to use file resource from LocalFileSystem.TEMPORARY directory");
            } else {
                // attempt to use path provided
                filePath = resourcePath;
                NSLog(@"Will attempt to use file resource '%@'", filePath);
            }
        } else {
            NSLog(@"Found resource '%@' in the web folder.", filePath);
        }
    }
    // if the resourcePath resolved to a file path, check that file exists
    if (filePath != nil) {
        NSURL * coverImageUrl = [NSURL URLWithString:filePath];
        NSData * coverImageData = [NSData dataWithContentsOfURL: coverImageUrl];
        coverImage = [UIImage imageWithData: coverImageData];
    }

    return [[MPMediaItemArtwork alloc] initWithImage:coverImage];
}


- (void)create:(CDVInvokedUrlCommand*)command {
    NSDictionary* audioInfo = [command argumentAtIndex:0];
    if(!audioInfo)return;
    NSLog(@"MusicControls::create++");

    NSNumber *useRemoteCommandCenter=[audioInfo objectForKey:@"useRemoteCommandCenter"];
    if(!useRemoteCommandCenter || [useRemoteCommandCenter boolValue]){
        //we use remote command center
        MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];

        //play
        MPRemoteCommand *playCommand = [rcc playCommand];
        [playCommand setEnabled:YES];
        [playCommand addTarget:self action:@selector(playEvent:)];

        //pause
        MPRemoteCommand *pauseCommand = [rcc pauseCommand];
        [pauseCommand setEnabled:YES];
        [pauseCommand addTarget:self action:@selector(pauseEvent:)];

        //togglePlayPause
        MPRemoteCommand *togglePPCommand = [rcc togglePlayPauseCommand];
        [togglePPCommand setEnabled:YES];
        [togglePPCommand addTarget:self action:@selector(playOrPauseEvent:)];

        //do we have skip forward?
        NSNumber *skipForwardValue=[audioInfo objectForKey:@"skipForwardValue"];
        if(skipForwardValue){
            NSLog(@"MusicControls::create: we have skipForward value: %@",skipForwardValue);
            MPSkipIntervalCommand *skipForwardIntervalCommand = [rcc skipForwardCommand];
            skipForwardIntervalCommand.preferredIntervals = @[skipForwardValue];
            [skipForwardIntervalCommand setEnabled:YES];
            [skipForwardIntervalCommand addTarget:self action:@selector(skipForwardEvent:)];
        }

        //do we have skip backward?
        NSNumber *skipBackwardValue=[audioInfo objectForKey:@"skipBackwardValue"];
        if(skipBackwardValue){
            NSLog(@"MusicControls::create: we have skipBackward value: %@",skipBackwardValue);
            MPSkipIntervalCommand *skipBackwardIntervalCommand = [rcc skipBackwardCommand];
            skipBackwardIntervalCommand.preferredIntervals = @[skipBackwardValue];
            [skipBackwardIntervalCommand setEnabled:YES];
            [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
        }
    }

    NSNumber *useNowPlayingInfo=[audioInfo objectForKey:@"useNowPlayingInfo"];
    if(!useNowPlayingInfo || [useNowPlayingInfo boolValue]){
        newInfo=[NSMutableDictionary dictionary];

        [self updateInfo:command];
    }

    NSLog(@"MusicControls::create--");
}


- (void)destroy:(CDVInvokedUrlCommand*)command {
    //remove all event targets
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    [rcc.playCommand removeTarget:self];
    [rcc.pauseCommand removeTarget:self];
    [rcc.togglePlayPauseCommand removeTarget:self];

    [rcc.skipForwardCommand removeTarget:self];
    [rcc.skipBackwardCommand removeTarget:self];

    //clear the now playing info
    NSNumber *clearNowPlayingInfo=[command argumentAtIndex:0 withDefault:nil];
    if(clearNowPlayingInfo && [clearNowPlayingInfo boolValue])
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
}

- (void)updateInfo:(CDVInvokedUrlCommand*)command {
    NSDictionary* audioInfo = [command argumentAtIndex:0];
    if(!audioInfo)return;

    //do we have a title?
    NSString *infoTitle=[audioInfo objectForKey:@"title"];
    if(infoTitle)
        [newInfo setObject:infoTitle forKey: MPMediaItemPropertyTitle];

    //do we have an album title?
    NSString *infoAlbumTitle=[audioInfo objectForKey:@"albumTitle"];
    if(infoAlbumTitle)
        [newInfo setObject:infoAlbumTitle forKey: MPMediaItemPropertyAlbumTitle];

    //do we have a track number?
    NSNumber *infoAlbumTrackNumber=[audioInfo objectForKey:@"albumTrackNumber"];
    if(infoAlbumTrackNumber)
        [newInfo setObject:infoAlbumTrackNumber forKey: MPMediaItemPropertyAlbumTrackNumber];

    //do we have a track count?
    NSNumber *infoAlbumTrackCount=[audioInfo objectForKey:@"albumTrackCount"];
    if(infoAlbumTrackCount)
        [newInfo setObject:infoAlbumTrackCount forKey: MPMediaItemPropertyAlbumTrackCount];

    //do we have duration?
    NSNumber *infoPlaybackDuration=[audioInfo objectForKey:@"playbackDuration"];
    if(infoPlaybackDuration)
        [newInfo setObject:infoPlaybackDuration forKey: MPMediaItemPropertyPlaybackDuration];

    //do we have position?
    NSNumber *infoPlaybackPosition=[audioInfo objectForKey:@"playbackPosition"];
    if(infoPlaybackPosition)
        [newInfo setObject:infoPlaybackPosition forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime];
    else
        [newInfo removeObjectForKey: MPNowPlayingInfoPropertyElapsedPlaybackTime];

    //do we have playback rate?
    NSNumber *infoPlaybackRate=[audioInfo objectForKey:@"playbackRate"];
    if(infoPlaybackRate)
        [newInfo setObject:infoPlaybackRate forKey: MPNowPlayingInfoPropertyPlaybackRate];

    //do we have artwork?
    NSString *infoArtwork=[audioInfo objectForKey:@"artwork"];
    if(infoArtwork){

        MPMediaItemArtwork *artwork = [self urlForArtwork:infoArtwork];
        if(artwork) {
            [newInfo setObject: artwork forKey: MPMediaItemPropertyArtwork];
        }

    }


    //update the information
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = newInfo;
}

- (void) playEvent:(MPRemoteCommandEvent*)event {
    NSString* jsString = jsString = [NSString stringWithFormat:@"%@(%d,%d);",
                @"cordova.require('cordova-music-remote-controls.MusicControls').onEvent",1,0];
    [self.commandDelegate evalJs:jsString];
}

- (void) pauseEvent:(MPRemoteCommandEvent*)event {
    NSString* jsString = jsString = [NSString stringWithFormat:@"%@(%d,%d);",
                @"cordova.require('cordova-music-remote-controls.MusicControls').onEvent",2,0];
    [self.commandDelegate evalJs:jsString];
}

- (void) playOrPauseEvent:(MPRemoteCommandEvent*)event {
    NSString* jsString = jsString = [NSString stringWithFormat:@"%@(%d,%d);",
                @"cordova.require('cordova-music-remote-controls.MusicControls').onEvent",3,0];
    [self.commandDelegate evalJs:jsString];
}

- (void) skipForwardEvent:(MPSkipIntervalCommandEvent *)event {
    NSLog(@"XXXXXXXXX SkipForwardEvent: %@",event);
    NSString* jsString = jsString = [NSString stringWithFormat:@"%@(%d,%f);",
                @"cordova.require('cordova-music-remote-controls.MusicControls').onEvent",4,event.interval];
    [self.commandDelegate evalJs:jsString];
}
- (void) skipBackwardEvent:(MPSkipIntervalCommandEvent *)event {
    NSLog(@"XXXXXXXXX SkipBackwardEvent: %@",event);
    NSString* jsString = jsString = [NSString stringWithFormat:@"%@(%d,%f);",
                @"cordova.require('cordova-music-remote-controls.MusicControls').onEvent",5,event.interval];
    [self.commandDelegate evalJs:jsString];
}

@end
