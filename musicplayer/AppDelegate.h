//
//  AppDelegate.h
//  MusicPlayer
//
//  Created by Anthony Olukitibi on 6/9/15.
//  Copyright (c) 2015 Anthony Olukitibi All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NSMutableArray+Shuffling.h"
#import <AdColony/AdColony.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSMutableArray *musicArray;
    int currentPlaying;
    
    AVPlayerItem *audioPlayer;
    AVPlayer *thePlayer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary *currentSong;
@property (strong, nonatomic) NSString *currentPlayList;

- (void) initializeWithPlayList:(NSString *)thePlayList;
- (void) playNextSong;
- (void) playPrevSong;
- (void) pauseTheSong;
- (void) playTheSong;
-(BOOL) songIsPaused;
-(void) downloadImageFor:(NSString *)theImageName;

@end

