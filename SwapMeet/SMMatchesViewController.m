//
//  SMMatchesViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMMatchesViewController.h"

@interface SMMatchesViewController ()

@property (strong, nonatomic) MFMailComposeViewController *mailViewController;
@property (strong, nonatomic) NSString *mailResult;

@end

@implementation SMMatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.mailResult = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.mailResult != nil) {
        [self presentAlertView:self.mailResult];
    }
}

#pragma mark - TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SEARCH_CELL"];
    cell.backgroundColor = [UIColor blueColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([MFMailComposeViewController canSendMail]) {
        self.mailViewController = [[MFMailComposeViewController alloc] init];
        [self.mailViewController setSubject:@"Let's Trade!"];
        [self.mailViewController setMessageBody:@"TEST" isHTML:NO];
        [self.mailViewController setToRecipients:@[@"reid_weber@hotmail.com"]];
        self.mailViewController.mailComposeDelegate = self;
        [self presentViewController:self.mailViewController animated:true completion:nil];
    } else {
        [self presentAlertView:@"You Cannot Send Mail At This Time"];
    }
}

#pragma mark - MailComposeViewController Delegate Method

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
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
            self.mailResult = @"Your Email Was Not Sent";
            break;
    }
    [controller dismissViewControllerAnimated:true completion:nil];
}

- (void) presentAlertView:(NSString *) result {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:result message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:true completion:nil];
}

@end
