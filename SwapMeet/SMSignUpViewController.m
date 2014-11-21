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
    
    [self.view setBackgroundColor:[UIColor colorWithRed:242/255. green:242/255. blue:246/255. alpha:1.0]];
    self.errorLabel.text = nil;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeTop];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [_emailTextField setRequired:YES];
    [_emailTextField setEmailField:YES];
    [_passwordTextField setRequired:YES];
    [_confirmPasswordTextField setRequired:YES];
    [_zipCodeTextField setRequired:YES];
    
    [self.navigationItem setTitle:@"Registration"];
    //NSLog(@"%@", self.navigationItem.backBarButtonItem.title);
    //self.navigationItem.backBarButtonItem.title = nil;
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    self.zipCodeTextField.delegate = self;
}

//- (void)textFieldWillShow:(NSNotification *)notification {
//    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    NSLog(@"%f",keyboardFrame.origin.y);
//}

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
            NSLog(@"Account created");
            NSLog(@"%@", profileDic);
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.screenNameTextField resignFirstResponder];
    [self.zipCodeTextField resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        if (textField == self.emailTextField) {
            if (self.emailTextField.text.length > 5) {
                if ([self validateEmailWithString:self.emailTextField.text] == true) {
                    self.errorLabel.text = nil;
                    return true;
                } else {
                    self.errorLabel.text = @"Not a valid e-mail address.";
                    return false;
                }
            } else {
                self.errorLabel.text = @"E-mail address is too short.";
                return false;
            }
            
        } else if (textField == self.passwordTextField) {
            BOOL lowerCaseLetter = 0;
            BOOL digit = 0;
            if ([textField.text length] >= 8 && [textField.text length] <= 12) {
                for (int i = 0; i < [textField.text length]; i++) {
                    unichar c = [textField.text characterAtIndex:i];
                    if (!lowerCaseLetter) {
                        lowerCaseLetter = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
                    }
                    if (!digit) {
                        digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
                    }
                }
                
                if (lowerCaseLetter && digit) {
                    self.errorLabel.text = nil;
                    return true;
                } else {
                    self.errorLabel.text = @"Please ensure that you have at least one lower case letter and one digit in your password.";
                    return false;
                }
            } else {
                self.errorLabel.text = @"Passwords must be 8-12 characters.";
                return false;
            }
            
        } else if (textField == self.confirmPasswordTextField) {
            NSString *password1 = self.passwordTextField.text;
            NSString *password2 = self.confirmPasswordTextField.text;
            if ([password1 isEqualToString:password2]) {
                self.errorLabel.text = nil;
                return true;
            } else {
                self.errorLabel.text = @"Passwords do not match.";
                return false;
            }
            
        } else if (textField == self.zipCodeTextField) {
            if ([self validateZipCodeWithString:self.zipCodeTextField.text] == true) {
                self.errorLabel.text = nil;
                [self.zipCodeTextField resignFirstResponder];
                return true;
            } else {
                self.errorLabel.text = @"Not a valid U.S. Postal Code.";
                return false;
            }
        }
    }
    
    self.errorLabel.text = nil;
    return true;
}

- (BOOL)validateEmailWithString:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validateZipCodeWithString:(NSString *)zipCode {
    NSString *zipRegex = @"^[0-9]{5}(-[0-9]{4})?$";
    NSPredicate *zipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", zipRegex];
    return [zipTest evaluateWithObject:zipCode];
}

@end
