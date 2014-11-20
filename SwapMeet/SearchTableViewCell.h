//
//  SearchTableViewCell.h
//  SwapMeet
//
//  Created by Reid Weber on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *platformName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
