//
//  MatchTableViewCell.m
//  SwapMeet
//
//  Created by Reid Weber on 11/20/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "MatchTableViewCell.h"

@implementation MatchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _hasGameImageView.layer.cornerRadius = 2;
    _wantsGameImageView.layer.cornerRadius = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
