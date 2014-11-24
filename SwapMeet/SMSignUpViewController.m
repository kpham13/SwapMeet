//
//  SMSignUpViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSignUpViewController.h"
#import "SMProfileViewController.h"
#import "SMNetworking.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MHTextField.h"

@interface SMSignUpViewController () {
    MBProgressHUD *hud;
    MHTextField *mhTextField;
}

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSNumber *zipCode;
@property (strong, nonatomic) NSString *screenName;

@end

@implementation SMSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeTop];
    
    //NSLog(@"%@", self.navigationItem.backBarButtonItem.title);
    //self.navigationItem.backBarButtonItem.title = nil;
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    self.screenNameTextField.delegate = self;
    self.zipCodeTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)signUpButton:(id)sender {
    self.email = self.emailTextField.text;
    self.password = self.passwordTextField.text;
    self.screenName = self.screenNameTextField.text;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    self.zipCode = [formatter numberFromString:self.zipCodeTextField.text];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [SMNetworking signUpWithEmail:self.email andPassword:self.password andScreenName:self.screenName zipNumber:self.zipCode completion:^(BOOL successful, NSDictionary *profileDic, NSString *errorString) {
        if (successful == YES) {
            //NSLog(@"Account created");
            //NSLog(@"%@", profileDic);
            NSString *profileEmail = [profileDic objectForKey:@"email"];
            NSString *profileScreenName = [profileDic objectForKey:@"screename"];
            NSString *profileZipCode = [profileDic objectForKey:@"zip"];
            [[NSUserDefaults standardUserDefaults] setObject:profileEmail forKey:kSMDefaultsKeyEmail];
            [[NSUserDefaults standardUserDefaults] setObject:profileScreenName forKey:kSMDefaultsKeyScreenName];
            [[NSUserDefaults standardUserDefaults] setObject:profileZipCode forKey:kSMDefaultsKeyZipCode];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Switch to delegation in the future
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
            
            NSInteger destinationTab = appDelegate.targetTab;
            if (destinationTab == 2) {
                [tabBarController setSelectedIndex:destinationTab];
            } else if (destinationTab == 3) {
                [tabBarController setSelectedIndex:destinationTab];
            }
            
            [hud hide:YES];
            [self dismissViewControllerAnimated:true completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login failed" message:errorString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *OKButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:OKButton];
            [self presentViewController:alert animated:true completion:nil];
            [hud hide:YES];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.screenNameTextField resignFirstResponder];
    [self.zipCodeTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.25 animations:^{
        if (textField == self.emailTextField) {
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } else if (textField == self.passwordTextField) {
            self.view.frame = CGRectMake(0, -28, self.view.frame.size.width, self.view.frame.size.height);
        } else if (textField == self.confirmPasswordTextField) {
            self.view.frame = CGRectMake(0, -78, self.view.frame.size.width, self.view.frame.size.height);
        } else if (textField == self.screenNameTextField) {
            self.view.frame = CGRectMake(0, -128, self.view.frame.size.width, self.view.frame.size.height);
        } else if (textField == self.zipCodeTextField) {
            self.view.frame = CGRectMake(0, -178, self.view.frame.size.width, self.view.frame.size.height);
        }
    } completion:^(BOOL finished) {
        //NSLog(@"Done!");
    }];

    // [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        //NSLog(@"Out of editing mode.");
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        if (textField == self.emailTextField) {
            if (self.emailTextField.text.length > 5) {
                if ([self validateEmailWithString:self.emailTextField.text] == true) {
                    if (self.emailErrorLabel.text != nil) {
                        [UIView animateWithDuration:30.0 animations:^{
                            self.constraintEmailToPassword.constant = 10;
                            self.emailErrorLabel.text = nil;
                        }];
                    }
                } else {
                    [UIView animateWithDuration:30.0 animations:^{
                        self.constraintEmailToPassword.constant = 24;
                        self.emailErrorLabel.text = @"Not a valid e-mail address.";
                    }];
                }
            } else {
                [UIView animateWithDuration:30.0 animations:^{
                    self.constraintEmailToPassword.constant = 24;
                    self.emailErrorLabel.text = @"E-mail address is too short.";
                }];
            }
            
        } else if (textField == self.passwordTextField) {
            BOOL letterCheck = 0;
            BOOL digitCheck = 0;
            if ([textField.text length] >= 8 && [textField.text length] <= 12) {
                for (int i = 0; i < [textField.text length]; i++) {
                    unichar c = [textField.text characterAtIndex:i];
                    if (!letterCheck) {
                        letterCheck = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
                    }
                    if (!digitCheck) {
                        digitCheck = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
                    }
                }
                
                if (letterCheck && digitCheck) {
                    if (self.passwordErrorLabel.text != nil) {
                        [UIView animateWithDuration:30.0 animations:^{
                            self.constraintPasswordToConfirm.constant = 10;
                            self.passwordErrorLabel.text = nil;
                        }];
                    }
                } else {
                    [UIView animateWithDuration:30.0 animations:^{
                        self.constraintPasswordToConfirm.constant = 24;
                        self.passwordErrorLabel.text = @"Passwords must have at least one letter and one digit.";
                    }];
                }
            } else {
                [UIView animateWithDuration:30.0 animations:^{
                    self.constraintPasswordToConfirm.constant = 24;
                    self.passwordErrorLabel.text = @"Passwords must be 8-12 characters.";
                }];
            }
            
        } else if (textField == self.confirmPasswordTextField) {
            NSString *password1 = self.passwordTextField.text;
            NSString *password2 = self.confirmPasswordTextField.text;
            if ([password1 isEqualToString:password2]) {
                [UIView animateWithDuration:30.0 animations:^{
                    self.constraintConfirmPasswordToScreenName.constant = 10;
                    self.confirmPasswordErrorLabel.text = nil;
                }];
            } else {
                [UIView animateWithDuration:30.0 animations:^{
                    self.constraintConfirmPasswordToScreenName.constant = 24;
                    self.confirmPasswordErrorLabel.text = @"Passwords do not match.";
                }];
            }
            
        } else if (textField == self.zipCodeTextField) {
            if ([self validateZipCodeWithString:self.zipCodeTextField.text] == true) {
                self.zipCodeErrorLabel.text = nil;
                [self.zipCodeTextField resignFirstResponder];
            } else {
                self.zipCodeErrorLabel.text = @"Not a valid U.S. Postal Code.";
            }
        }
    } else if (textField.text.length == 0) {
        if (textField == self.emailTextField) {
            [UIView animateWithDuration:30.0 animations:^{
                self.constraintEmailToPassword.constant = 10;
                self.emailErrorLabel.text = nil;
            }];
        } else if (textField == self.passwordTextField) {
            [UIView animateWithDuration:30.0 animations:^{
                self.constraintPasswordToConfirm.constant = 10;
                self.passwordErrorLabel.text = nil;
            }];
        } else if (textField == self.confirmPasswordTextField) {
            [UIView animateWithDuration:30.0 animations:^{
                self.constraintConfirmPasswordToScreenName.constant = 10;
                self.confirmPasswordErrorLabel.text = nil;
            }];
        } else if (textField == self.zipCodeTextField) {
            self.zipCodeErrorLabel.text = nil;
        }
    }
    
    return true;
}

- (BOOL)validateEmailWithString:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validateZipCodeWithString:(NSString *)zipCode {
    NSString *zipCodeRegex = @"^[0-9]{5}(-[0-9]{4})?$";
    NSPredicate *zipCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", zipCodeRegex];
    return [zipCodeTest evaluateWithObject:zipCode];
}

- (void)setupViewController {
    [self.navigationItem setTitle:@"Registration"];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:242/255. green:242/255. blue:246/255. alpha:1.0]];
    
    self.emailErrorLabel.text = nil;
    self.passwordErrorLabel.text = nil;
    self.confirmPasswordErrorLabel.text = nil;
    self.zipCodeErrorLabel.text = nil;
    
    // Text Field Delegate Setup
    [_emailTextField setRequired:YES];
    [_emailTextField setEmailField:YES];
    [_passwordTextField setRequired:YES];
    [_confirmPasswordTextField setRequired:YES];
    [_zipCodeTextField setRequired:YES];
}

@end
