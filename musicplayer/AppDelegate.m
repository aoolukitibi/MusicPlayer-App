//
//  AppDelegate.m
//  MusicPlayer
//
//  Created by Anthony Olukitibi on 6/9/15.
//  Copyright (c) 2015 Anthony Olukitibi All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

@interface AppDelegate () <UIAlertViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self loadMusicIntoApp];
    
    [AdColony configureWithAppID:@"app781985c05ef8428d9b"
                         zoneIDs:@[@"vz8cabc733a2484c0eac"]
                        delegate:nil
                         logging:YES];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0 green:51.0/255.0 blue:102.0/255.0 alpha:1.0], NSForegroundColorAttributeName,  [UIFont boldSystemFontOfSize:17], NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];

    return YES;
}

-(void) loadMusicIntoApp {
    NSUserDefaults *prefs =
    [NSUserDefaults standardUserDefaults];
    NSArray *defaultArray = [prefs objectForKey:@"playlist"];
    NSArray *basicArray = @[@"Rock",@"Pop",@"Country", @"Grunge", @"Punk", @"Blues"];
    if(!defaultArray) {
        [prefs setObject:basicArray forKey:@"playlist"];
        [prefs synchronize];
        for(NSString *theObject in basicArray){
            [self downloadImageFor:[theObject stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        }
    } else {
        for(NSString *theObject in defaultArray){
            [self downloadImageFor:[theObject stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        }
    }
    

}

-(void) downloadImageFor:(NSString *)theImageName {
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* theImageFile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",theImageName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:theImageFile];
    
    if(!fileExists) {
        
        NSString *downloadURL = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=song&limit=1",theImageName];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:downloadURL]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    
                    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    
                    NSString *theStringUrl = [[[dataDictionary objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artworkUrl100"];
                    
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:theStringUrl]]];
                    
                    NSData* imageData = UIImagePNGRepresentation(image);
                    
                    [imageData writeToFile:theImageFile atomically:YES];
                    [self performSelectorOnMainThread:@selector(sendNotification) withObject:nil waitUntilDone:NO];
                    
                }] resume];
        
    } else {
        //NSLog(@"FILE EXISTS");
    }
}

-(void) sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownloaded" object:nil];
}

- (void) initializeWithPlayList:(NSString *)thePlayList {
    self.currentPlayList = thePlayList;
    if(musicArray){
        [musicArray removeAllObjects];
        musicArray = nil;
    }
    musicArray = [[NSMutableArray alloc] init];
    currentPlaying = 0;
    
    NSString *downloadURL = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=song&limit=200",thePlayList];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:downloadURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                [self performSelectorOnMainThread:@selector(displayStuffUsingData:) withObject:data waitUntilDone:YES];
                
            }] resume];
    
    
}

-(void) displayStuffUsingData:(NSData *) data {
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
        [nav popViewControllerAnimated:YES];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check your Internet Connection" message:@"Cannot connect to Server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    musicArray = [dataDictionary objectForKey:@"results"];
    if(musicArray.count == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Songs Available" message:@"For this Playlist" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    } else {
        if(musicArray.count < 100){
            NSString *musicGenre = [[musicArray objectAtIndex:0] objectForKey:@"primaryGenreName"];
            [self initializeWithPlayList:musicGenre];
        } else {
            [musicArray shuffle];
            [self itemDidFinishPlaying:nil];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [nav popViewControllerAnimated:YES];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    
    if(currentPlaying+1 >= musicArray.count){
        currentPlaying = 0;
    }
    
    self.currentSong = [musicArray objectAtIndex:currentPlaying++];
    
    if(audioPlayer){
        audioPlayer = nil;
    }
    
    audioPlayer = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[self.currentSong objectForKey:@"previewUrl"]]];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:audioPlayer];
    
    thePlayer = [AVPlayer playerWithPlayerItem:audioPlayer];
    [self playTheSong];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SongChanged" object:nil];
    
}

- (void) playNextSong{
    [self itemDidFinishPlaying:nil];
}

- (void) playPrevSong{
    currentPlaying -= 2;
    if(currentPlaying < 0){
        currentPlaying = (int)musicArray.count - 2;
    }
    [self itemDidFinishPlaying:nil];
}

-(void) pauseTheSong {
    [thePlayer pause];
}

- (void) playTheSong{
    [thePlayer play];
    NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyAlbumTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyArtwork, nil];
    
    NSString *theStringUrl = [self.currentSong objectForKey:@"artworkUrl100"];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:theStringUrl]]];
    
    CGSize thumbnailSize = CGSizeMake(100.0, 100.0);
    MPMediaItemArtwork *albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:image];
    [albumArtwork imageWithSize:thumbnailSize];

    
    NSArray *values = [NSArray arrayWithObjects:[self.currentSong objectForKey:@"trackName"], [self.currentSong objectForKey:@"artistName"], albumArtwork, nil];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self playTheSong];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self pauseTheSong];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self playNextSong];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self playPrevSong];
            break;
        default:
            break;
    }
}

-(BOOL) songIsPaused{
    if (thePlayer.rate > 0 && !thePlayer.error) {
        return YES;
    }
    return NO;
}


@end
