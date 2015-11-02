//
//  ViewController.m
//  MusicPlayer
//
//  Created by Anthony Olukitibi on 6/9/15.
//  Copyright (c) 2015 Anthony Olukitibi All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <AdColony/AdColony.h>

@interface ViewController () <UIAlertViewDelegate, AdColonyAdDelegate> {
    int showAdCount;
}

@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;
@property (weak, nonatomic) IBOutlet UILabel *songNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *artworkBackground;
@property (weak, nonatomic) IBOutlet UIButton *playPauseBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.view.bounds;
    [self.artworkBackground addSubview:effectView];
    
    self.holderView.layer.cornerRadius = 20;
    self.holderView.layer.masksToBounds = YES;
    self.holderView.alpha = 0.7;

        
    showAdCount = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawTheSong) name:@"SongChanged" object:nil];
    
    if(self.playlist){
        [self startUpPlaying];
    } else {
        [self drawTheSong];
    }
}

-(void) startUpPlaying {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate.currentPlayList isEqualToString:self.playlist]){
        [self drawTheSong];
    } else {
        [appDelegate initializeWithPlayList:self.playlist];
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* theImageFile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.playlist]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:theImageFile];
        if(fileExists){
            self.artworkImage.image = [UIImage imageWithContentsOfFile:theImageFile];
            self.artworkBackground.image = [UIImage imageWithContentsOfFile:theImageFile];
        } else {
            self.artworkImage.image = [UIImage imageNamed:@"album.png"];
            self.artworkBackground.image = [UIImage imageNamed:@"album.png"];

        }

    }
}

-(void) drawTheSong {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSDictionary *theSong = appDelegate.currentSong;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[theSong objectForKey:@"artworkUrl100"]]]];
    self.artworkImage.image = image;
    self.artworkBackground.image = image;
    self.songNameLbl.text = [theSong objectForKey:@"trackName"];
    self.artistNameLbl.text = [theSong objectForKey:@"artistName"];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* theImageFile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.playlist]];
    
    NSData* imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:theImageFile atomically:YES];
}

-(void) showTheAd {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate pauseTheSong];
    [AdColony playVideoAdForZone:@"vz8cabc733a2484c0eac" withDelegate:self];
}

- (void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate playNextSong];
}

- (void) onAdColonyAdFinishedWithInfo:(AdColonyAdInfo *)info{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate playNextSong];
}


- (IBAction)nextSong:(id)sender {
    showAdCount++;
    if(showAdCount == 5){
        [self showTheAd];
        showAdCount = 0;
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate playNextSong];
}

- (IBAction)prevSong:(id)sender {
    showAdCount++;
    if(showAdCount == 5){
        [self showTheAd];
        showAdCount = 0;
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate playPrevSong];
}

- (IBAction)pauseSong:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.playPauseBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];

    if(![appDelegate songIsPaused]){
        [appDelegate playTheSong];
        [self.playPauseBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    } else {
        [appDelegate pauseTheSong];
        [self.playPauseBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

@end
