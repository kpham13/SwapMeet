//
//  SMSignUpViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSignUpViewController.h"
#import "SMNetworking.h"

@interface SMSignUpViewController ()

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSNumber *zipCode;
@property (strong, nonatomic) NSString *screenName;

@end

@implementation SMSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

    [SMNetworking signUpWithEmail:self.email andPassword:self.password zipNumber:self.zipCode completion:^(BOOL successful, NSString *errorString) {
        //NSLog(@"Did this work?");
        if (successful == YES) {
            NSLog(@"Account created");
            // NetworkController method to retrieve user information & populate NSUserDefaults
            [self dismissViewControllerAnimated:true completion:nil];
        } else {
            NSLog(@"%@", errorString);
        }
    }];
}

@end
