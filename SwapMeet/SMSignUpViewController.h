//
//  SMSignUpViewController.h
//  SwapMeet
//
//  Created by Kevin Pham on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMSignUpViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *screenNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)signUpButton:(id)sender;
- (BOOL)validateEmailWithString:(NSString *)email;

@end
