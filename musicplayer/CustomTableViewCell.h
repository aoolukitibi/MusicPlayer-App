//
//  CustomTableViewCell.h
//  MusicPlayer
//
//  Created by Anthony Olukitibi on 6/16/15.
//  Copyright (c) 2015 Anthony Olukitibi All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;
@property (weak, nonatomic) IBOutlet UILabel *bandName;

@end
