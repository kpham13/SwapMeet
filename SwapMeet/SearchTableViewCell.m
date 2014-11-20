//
//  SearchTableViewCell.m
//  SwapMeet
//
//  Created by Reid Weber on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SearchTableViewCell.h"

@interface SearchTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *starActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *starringView;
@property (weak, nonatomic) IBOutlet UIView *platformBackgroundView;
@end

@implementation SearchTableViewCell

#pragma mark - Public Methods

- (void)startStarUpdate {
    [UIView transitionWithView:_starringView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_starActivityIndicator startAnimating];
        _starImageView.alpha = 0;
    } completion:nil];
}

- (void)finishStarUpdate:(BOOL)starred {
    [UIView transitionWithView:_starringView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_starActivityIndicator stopAnimating];
        self.starred = starred;
        _starImageView.alpha = 1;
    } completion:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"platformName.text"]) {
        _platformBackgroundView.hidden = !_platformName.text || [_platformName.text isEqualToString:@""];
    } else if ([keyPath isEqualToString:@"mode"]) {
        _starringView.hidden = _mode == SearchTableViewCellModeGames;
    } else if ([keyPath isEqualToString:@"starred"]) {
        _starImageView.image = [UIImage imageNamed:_starred ? @"star_selected" : @"star"];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)awakeFromNib {
    // Initialization code
    _platformBackgroundView.layer.cornerRadius = 2;
    _thumbnailImageView.layer.cornerRadius = 4;
    [self addObserver:self forKeyPath:@"platformName.text" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"mode" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"starred" options:NSKeyValueObservingOptionNew context:nil];
    _platformName.text = nil;
    self.mode = SearchTableViewCellModeGames;
}

- (void)prepareForReuse {
    _platformName.text = nil;
    _thumbnailImageView.image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    _platformBackgroundView.backgroundColor = [UIColor lightGrayColor];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"platformName.text"];
    [self removeObserver:self forKeyPath:@"mode"];
    [self removeObserver:self forKeyPath:@"starred"];
}

@end
