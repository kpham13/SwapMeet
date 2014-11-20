//
//  SMSignUpViewController.h
//  SwapMeet
//
//  Created by Kevin Pham on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMSignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *screenNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;

- (IBAction)signUpButton:(id)sender;

@end