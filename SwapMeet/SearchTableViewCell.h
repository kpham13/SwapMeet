//
//  SearchTableViewCell.h
//  SwapMeet
//
//  Created by Reid Weber on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SearchTableViewCellModeGames,
    SearchTableViewCellModeSearch
} SearchTableViewCellMode;

@interface SearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *platformName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
@property (weak, nonatomic) IBOutlet UIView *conditionContainerView;
@property (nonatomic) SearchTableViewCellMode mode;
@property (nonatomic) BOOL starred;

- (void)startStarUpdate;
- (void)finishStarUpdate:(BOOL)starred;

@end
