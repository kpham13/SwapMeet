//
//  SMMatchDetailViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMMatchDetailViewController.h"

@interface SMMatchDetailViewController ()

@property (strong, nonatomic) MFMailComposeViewController *mailViewController;
@property (strong, nonatomic) NSString *mailResult;

@end

@implementation SMMatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.mailViewController.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)contactButtonClicked:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        self.mailViewController = [[MFMailComposeViewController alloc] init];
        [self.mailViewController setSubject:@"Let's Trade!"];
        [self.mailViewController setMessageBody:@"TEST" isHTML:NO];
        [self.mailViewController setToRecipients:@[@"reid_weber@hotmail.com"]];
        self.mailViewController.mailComposeDelegate = self;
        [self presentViewController:self.mailViewController animated:true completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:true completion:nil];
    
    switch (result) {
        case MFMailComposeResultCancelled:
            self.mailResult = @"You Cancelled Your Email";
            break;
        case MFMailComposeResultFailed:
            self.mailResult = @"Your Email Failed To Send";
            break;
        case MFMailComposeResultSaved:
            self.mailResult = @"Your Email Has Been Saved";
            break;
        case MFMailComposeResultSent:
            self.mailResult = @"Your Email Has Been Sent";
            break;
        default:
            self.mailResult = @"There Was An Error.";
            break;
    }
    [controller dismissViewControllerAnimated:true completion:nil];
    [self presentAlertView:self.mailResult];
}

- (UIAlertController *) presentAlertView:(NSString *) result {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:result message:result preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction:action];
    return alertController;
}

@end
