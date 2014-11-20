//
//  SMMatchesViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMMatchesViewController.h"
#import "MatchTableViewCell.h"

@interface SMMatchesViewController ()

@property (strong, nonatomic) MFMailComposeViewController *mailViewController;
@property (strong, nonatomic) NSString *mailResult;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation SMMatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
    [self.refreshControl setAttributedTitle: title];
    [self.refreshControl addTarget:self action:@selector(refreshPage:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    self.mailResult = nil;
    [self.tableView registerNib:[UINib nibWithNibName:@"MatchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MATCH_CELL"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
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
    MatchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MATCH_CELL"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
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

#pragma mark - Refresh Method

-(void) refreshPage:(UIRefreshControl *)refreshControl {
    NSLog(@"Page is Refreshing");
    [refreshControl endRefreshing];
}

@end
