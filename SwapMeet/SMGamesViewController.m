//
//  SMGamesViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMGamesViewController.h"
#import "SMAddGameViewController.h"
#import "CoreDataController.h"
#import "SearchTableViewCell.h"
#import "SMNetworking.h"

@interface SMGamesViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property UIActivityIndicatorView *activityIndicator;

@end

@implementation SMGamesViewController

- (IBAction)addButtonClicked:(id)sender {
    SMAddGameViewController *addGameVC = [[SMAddGameViewController alloc] initWithNibName:@"SMAddGameViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:addGameVC animated:true completion:nil];
}

- (IBAction)changeSegment:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        //self.tableView.hidden = true;
        NSLog(@"My Games");
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        //self.tableView.hidden = false;
        NSLog(@"Favorites");
    }
    
    [self.tableView reloadData];
}


- (void)favoriteAdded:(NSNotification *)notification {
    NSLog(@"Favorite Added");
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:@"ADDED_FAVORITE" object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GAME_CELL"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_tableView.frame), CGRectGetMinY(_tableView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMinY(_tableView.frame))];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicator.color = [UIColor colorWithWhite:0.2 alpha:1];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view insertSubview:_activityIndicator aboveSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    self.fetchController = [[CoreDataController controller] fetchUserGames];
    self.fetchController.delegate = self;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegates Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL"];
    
    //if (self.segmentedControl.selectedSegmentIndex == 0) {
        Game *selectedGame = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
        cell.titleLabel.text = selectedGame.title;
        cell.platformName.text = selectedGame.platform;
    //} else if (self.segmentedControl.selectedSegmentIndex == 1) {
        
    //}
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchController.fetchedObjects count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.fetchController != nil) {
            __block Game *game = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
            if (!game)
                return;
            
            [_activityIndicator startAnimating];
            [SMNetworking deleteUserGameWithID:game.gameID completion:^(BOOL success, NSString *errorString) {
                [_activityIndicator stopAnimating];
                if (success) {
                    [[CoreDataController controller] deleteGame:game];
                    [[CoreDataController controller] saveContext];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Deletion failed" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark NSFetchedResultsController Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case 1:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 2:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 3:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 4:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

@end
