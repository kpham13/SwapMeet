//
//  SMLoginViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMLoginViewController.h"
#import "SMProfileViewController.h"
#import "SMSignUpViewController.h"
#import "SMNetworking.h"
#import "AppDelegate.h"

@interface SMLoginViewController ()

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

@end

@implementation SMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Profile VC"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController:)];
    [self.navigationItem setRightBarButtonItem:cancelButton animated:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)loginButton:(id)sender {
    self.email = self.emailTextField.text;
    self.password = self.passwordTextField.text;
    
    [SMNetworking loginWithEmail:self.email andPassword:self.password completion:^(BOOL successful, NSString *errorString) {
        if (successful == YES) {
            NSLog(@"Login success.");
            [self dismissViewControllerAnimated:true completion:nil];
            
            // Switch to delegation in the future
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
            [tabBarController setSelectedIndex:3];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login failed" message:errorString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *OKButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:OKButton];
            [self presentViewController:alert animated:true completion:nil];
        }
    }];
}

- (IBAction)registerButton:(id)sender {
    SMSignUpViewController *signUpViewController = [[SMSignUpViewController alloc] initWithNibName:@"SMSignUpViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:signUpViewController animated:true];
}

- (void)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
