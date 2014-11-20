//
//  SearchTableViewCell.m
//  SwapMeet
//
//  Created by Reid Weber on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SearchTableViewCell.h"

@interface SearchTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *platformBackgroundView;
@end

@implementation SearchTableViewCell

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"platformName.text"]) {
        _platformBackgroundView.hidden = !_platformName.text || [_platformName.text isEqualToString:@""];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)awakeFromNib {
    // Initialization code
    _platformBackgroundView.layer.cornerRadius = 2;
    [self addObserver:self forKeyPath:@"platformName.text" options:NSKeyValueObservingOptionNew context:nil];
    _platformName.text = nil;
}

- (void)prepareForReuse {
    _platformName.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"platformName.text"];
}

@end
