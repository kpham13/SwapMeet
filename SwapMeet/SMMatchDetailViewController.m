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

@end

@implementation SMMatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)contactButtonClicked:(id)sender {
    self.mailViewController = [[MFMailComposeViewController alloc] init];
    self.mailViewController.delegate = self;
    [self.mailViewController setSubject:@"Let's Trade!"];
    [self.mailViewController setMessageBody:@"TEST" isHTML:NO];
    [self.mailViewController setToRecipients:@[@"reid_weber@hotmail.com"]];
    [self presentViewController:self.mailViewController animated:true completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail Cancelled");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail Failed");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail Saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail Sent");
            break;
        default:
            break;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
