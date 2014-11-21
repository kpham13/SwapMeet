//
//  SMLoginViewController.h
//  SwapMeet
//
//  Created by Kevin Pham on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTextField.h"

@interface SMLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet SMTextField *emailTextField;
@property (weak, nonatomic) IBOutlet SMTextField *passwordTextField;

- (IBAction)loginButton:(id)sender;
- (IBAction)registerButton:(id)sender;
- (void)dismissViewController:(id)sender;

@end
