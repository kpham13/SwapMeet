//
//  SMLoginViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMLoginViewController.h"
#import "SMSignUpViewController.h"

@interface SMLoginViewController ()

@end

@implementation SMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)loginButton:(id)sender {
}

- (IBAction)registerButton:(id)sender {
    SMSignUpViewController *signUpViewController = [[SMSignUpViewController alloc] initWithNibName:@"SMSignUpViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:signUpViewController animated:true completion:nil];
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
