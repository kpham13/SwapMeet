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
#import <MBProgressHUD/MBProgressHUD.h>

@interface SMGamesViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) UIBarButtonItem *addGameButton;


@end

@implementation SMGamesViewController

- (IBAction)changeSegment:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSLog(@"My Games");
        self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
        self.navigationItem.rightBarButtonItem = self.addGameButton;
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        NSLog(@"Favorites");
        self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self.tableView reloadData];
}

- (void)addButtonClicked:(id)sender {
    SMAddGameViewController *addGameVC = [[SMAddGameViewController alloc] initWithNibName:@"SMAddGameViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:addGameVC animated:true completion:nil];
}

- (void)favoriteAdded:(NSNotification *)notification {
    NSLog(@"Favorite Added");
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.addGameButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
    self.navigationItem.rightBarButtonItem = self.addGameButton;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:@"ADDED_FAVORITE" object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GAME_CELL"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
    self.fetchController.delegate = self;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegates Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL"];
    Game *selectedGame = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
    cell.titleLabel.text = selectedGame.title;
    cell.platformName.text = selectedGame.platform;
    NSString *imagePath = selectedGame.imagePath;
    if (imagePath) {
        NSString *imageFullPath = [[[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] isDirectory:YES] URLByAppendingPathComponent:imagePath] path];
        UIImage *image = [UIImage imageWithContentsOfFile:imageFullPath];
        cell.thumbnailImageView.image = image;
    } else {
        cell.thumbnailImageView.image = nil;
    }

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
            
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [SMNetworking deleteUserGameWithID:game.gameID completion:^(BOOL success, NSString *errorString) {
                [hud hide:YES];
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
