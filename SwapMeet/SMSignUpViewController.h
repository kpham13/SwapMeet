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

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet SMTextField *emailTextField;
@property (weak, nonatomic) IBOutlet SMTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet SMTextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet SMTextField *screenNameTextField;
@property (weak, nonatomic) IBOutlet SMTextField *zipCodeTextField;

@property (weak, nonatomic) IBOutlet UILabel *emailErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmPasswordErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeErrorLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintEmailToPassword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPasswordToConfirm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintConfirmPasswordToScreenName;

- (IBAction)signUpButton:(id)sender;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
- (BOOL)validateEmailWithString:(NSString *)email;
- (BOOL)validateZipCodeWithString:(NSString *)zipCode;
- (void)setupViewController;

@end
