//
//  MatchTableViewCell.h
//  SwapMeet
//
//  Created by Reid Weber on 11/20/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *hasGameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wantsGameImageView;
@property (weak, nonatomic) IBOutlet UILabel *hasGameTitle;
@property (weak, nonatomic) IBOutlet UILabel *wantsGameTitle;
@property (weak, nonatomic) IBOutlet UIImageView *sendEmailImage;

@end
