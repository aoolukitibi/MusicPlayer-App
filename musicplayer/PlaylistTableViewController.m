//
//  PlaylistTableViewController.m
//  MusicPlayer
//
//  Created by Anthony Olukitibi on 6/9/15.
//  Copyright (c) 2015 Anthony Olukitibi All rights reserved.
//

#import "PlaylistTableViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "CustomTableViewCell.h"

@interface PlaylistTableViewController ()<UIAlertViewDelegate> {
    NSMutableArray *defaultPlaylists;
}

@end

@implementation PlaylistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    defaultPlaylists = [[NSMutableArray alloc] init];
    
    [self getDefaults];
//                        initWithArray:@[@"Rock",@"Pop",@"Country", @"Grunge", @"Punk", @"Blues"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"ImageDownloaded" object:nil];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void) getDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *defaultArray = [prefs objectForKey:@"playlist"];
    NSArray *basicArray = @[@"Rock",@"Pop",@"Country", @"Grunge", @"Punk", @"Blues"];
    if(defaultArray) {
        [defaultPlaylists addObjectsFromArray:defaultArray];
    } else {
        [defaultPlaylists addObjectsFromArray:basicArray];
        [prefs setObject:basicArray forKey:@"playlist"];
        [prefs synchronize];
    }

}

- (IBAction)addNewPlaylist:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create New Playlist"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if([[[alertView textFieldAtIndex:0].text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        return;
    }
    
    [defaultPlaylists insertObject:[alertView textFieldAtIndex:0].text atIndex:0];
    [self.tableView reloadData];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *theArray = defaultPlaylists;
    [prefs setObject:theArray forKey:@"playlist"];
    [prefs synchronize];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate downloadImageFor:[[alertView textFieldAtIndex:0].text stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
}


#pragma mark - Table view data source


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;//2;
}

//- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if(section == 0){
//        return @"Playlists";
//    }
//    if(section == 1){
//        return @"Offline Playlists";
//    }
//    return @"Other";
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1){
        return 2;
    }
    return defaultPlaylists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistCell" forIndexPath:indexPath];
    
    if(indexPath.section == 0){
        //cell.textLabel.text = [defaultPlaylists objectAtIndex:indexPath.row];
        cell.bandName.text = [[defaultPlaylists objectAtIndex:indexPath.row] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                            withString:[[[defaultPlaylists objectAtIndex:indexPath.row] substringToIndex:1] capitalizedString]];
        
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* theImageFile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[[defaultPlaylists objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:theImageFile];
        if(fileExists){
            cell.artworkImage.image = [UIImage imageWithContentsOfFile:theImageFile];
        } else {
            cell.artworkImage.image = [UIImage imageNamed:@"album.png"];
        }
        
        
    } else {
        if(indexPath.row == 0){
            cell.textLabel.text = @"Liked Songs";
        } else {
            cell.textLabel.text = @"Disliked Songs";
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [defaultPlaylists removeObjectAtIndex:indexPath.row];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:defaultPlaylists forKey:@"playlist"];
        [prefs synchronize];
        [self.tableView reloadData];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"nowPlaying"]){
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        
        ViewController *vc = (ViewController *)segue.destinationViewController;
        vc.title = appDelegate.currentPlayList;
        vc.playlist = nil;
        
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ViewController *vc = (ViewController *)segue.destinationViewController;
    vc.title = [[defaultPlaylists objectAtIndex:indexPath.row] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                       withString:[[[defaultPlaylists objectAtIndex:indexPath.row] substringToIndex:1] capitalizedString]];;
    vc.playlist = [[defaultPlaylists objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if([identifier isEqualToString:@"nowPlaying"]){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(!appDelegate.currentPlayList){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Playing Anything" message:@"Select A Playlist" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}

- (void)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [defaultPlaylists exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}


@end
