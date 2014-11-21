//
//  SMMatchesViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMMatchesViewController.h"
#import "MatchTableViewCell.h"
#import "SMNetworking.h"
#import "Game.h"
#import "CoreDataController.h"

@interface SMMatchesViewController () {
    NSArray *matchesArray;
    BOOL loaded;
}

@property (strong, nonatomic) MFMailComposeViewController *mailViewController;
@property (strong, nonatomic) NSString *mailResult;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation SMMatchesViewController

#pragma mark - Private Methods

- (void)downloadMatches {
    [SMNetworking matchesWithCompletion:^(NSArray *matches, NSString *errorString) {
        [_refreshControl endRefreshing];
        if (errorString) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        matchesArray = matches;
        [_tableView reloadData];
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.mailResult = nil;
    [self.tableView registerNib:[UINib nibWithNibName:@"MatchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MATCH_CELL"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    [self setUpRefreshControl];
    
    matchesArray = [NSArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!loaded) {
        loaded = YES;
        [self downloadMatches];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *tmp = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] isDirectory:YES];
    
    MatchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MATCH_CELL"];
    cell.hasGameImageView.image = nil;
    cell.wantsGameImageView.image = nil;
    cell.hasGameTitle.text = nil;
    cell.wantsGameTitle.text = nil;
    NSDictionary *match = matchesArray[indexPath.row];
    Game *myGame = [[CoreDataController controller] gameWithID:[match valueForKeyPath:@"mygame.gameId"]];
    if (myGame) {
        cell.hasGameTitle.text = myGame.title;
        if (myGame.imagePath) {
            NSString *fullPath = [[tmp URLByAppendingPathComponent:myGame.imagePath] path];
            cell.hasGameImageView.image = [UIImage imageWithContentsOfFile:fullPath];
        }
        
        Game *yourGame = [[CoreDataController controller] gameWithID:[match valueForKeyPath:@"yourgame._id"]];
        if (yourGame) {
            cell.wantsGameTitle.text = yourGame.title;
            if (yourGame.imagePath) {
                NSString *fullPath = [[tmp URLByAppendingPathComponent:yourGame.imagePath] path];
                cell.wantsGameImageView.image = [UIImage imageWithContentsOfFile:fullPath];
            }
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [matchesArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *match = matchesArray[indexPath.row];
    NSLog(@"%@", match);
    if ([MFMailComposeViewController canSendMail]) {
        self.mailViewController = [[MFMailComposeViewController alloc] init];
        [self.mailViewController setSubject:@"Let's Trade!"];
        [self.mailViewController setMessageBody:@"Hi. We have a match in SwapMeet. Let's trade!" isHTML:NO];
        [self.mailViewController setToRecipients:@[[match valueForKeyPath:@"you.email"]]];
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
            [self presentAlertView:self.mailResult];
            break;
        case MFMailComposeResultSaved:
            self.mailResult = @"Your Email Has Been Saved";
            break;
        case MFMailComposeResultSent:
            self.mailResult = @"Your Email Has Been Sent";
            [self presentAlertView:self.mailResult];
            break;
        default:
            self.mailResult = @"Your Email Was Not Sent";
            [self presentAlertView:self.mailResult];
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

- (void) refreshPage:(UIRefreshControl *)refreshControl {
    NSLog(@"Page is Refreshing");
    [self downloadMatches];
}

- (void) setUpRefreshControl {
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
    [self.refreshControl setAttributedTitle: title];
    [self.refreshControl addTarget:self action:@selector(refreshPage:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
}

@end
