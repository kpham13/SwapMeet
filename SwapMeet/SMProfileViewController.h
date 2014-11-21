//
//  SMProfileViewController.h
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMLoginViewController.h"

extern NSString * const kSMDefaultsKeyEmail;
extern NSString * const kSMDefaultsKeyScreenName;
extern NSString * const kSMDefaultsKeyZipCode;
extern NSString * const kSMDefaultsKeyAvatarURL;

@interface SMProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;

- (IBAction)logoutButton:(id)sender;

@end
