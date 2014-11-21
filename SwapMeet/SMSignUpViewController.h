//
//  SMSignUpViewController.h
//  SwapMeet
//
//  Created by Kevin Pham on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTextField.h"

@interface SMSignUpViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet SMTextField *emailTextField;
@property (weak, nonatomic) IBOutlet SMTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet SMTextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet SMTextField *screenNameTextField;
@property (weak, nonatomic) IBOutlet SMTextField *zipCodeTextField;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)signUpButton:(id)sender;
- (BOOL)validateEmailWithString:(NSString *)email;

@end
