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

@interface SMProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *lookingForTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (IBAction)logoutButton:(id)sender;

@end