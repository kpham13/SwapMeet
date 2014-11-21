//
//  SMSearchViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSearchViewController.h"
#import "SMNetworking.h"
#import "SearchTableViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Game.h"
#import "CoreDataController.h"

@interface SMSearchViewController () {
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *gamesArray;
@property (nonatomic) NSURLSessionDataTask *searchTask;
@property BOOL canLoadMore;

@end

@implementation SMSearchViewController

#pragma mark - Private Methods

- (void)searchAtOffset:(NSInteger)offset {
    _canLoadMore = NO;
    _searchTask = [SMNetworking gamesContaining:_searchBar.text forPlatform:nil atOffset:offset completion:^(NSArray *objects, NSInteger itemsLeft, NSString *errorString) {
        _canLoadMore = itemsLeft > 0;
        NSLog(@"Count: %ld. Items left: %ld", (long)[objects count], (long)itemsLeft);
        [hud hide:YES];
        if (errorString) {
            NSLog(@"%@", errorString);
            return;
        }
        
        [_gamesArray addObjectsFromArray:objects];
        [_tableView reloadData];
    }];
}

- (void)deletedFavorite:(NSNotification *)notification {
    NSString *favoriteID = notification.userInfo[@"id"];
    if (favoriteID) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id = %@", favoriteID];
        NSArray *filteredArray = [_gamesArray filteredArrayUsingPredicate:predicate];
        if ([filteredArray count] > 0) {
            NSMutableDictionary *gameDic = [filteredArray firstObject];
            gameDic[@"already_wanted"] = @(NO);
            [_tableView reloadData];
        }
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate =self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GAME_CELL"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 70;
    
    self.gamesArray = [NSMutableArray array];
    _canLoadMore = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletedFavorite:) name:@"FAVORITE_DELETED" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ADDED_FAVORITE" object:self userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView Delegates Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL"];
    cell.mode = SearchTableViewCellModeSearch;
    [cell.activityIndicator stopAnimating];
    NSDictionary *gameDic = _gamesArray[indexPath.row];
    cell.titleLabel.text = gameDic[@"title"];
    cell.platformName.text = gameDic[@"platform"];
    cell.starred = [gameDic[@"already_wanted"] boolValue];
    NSString *thumbURL = [gameDic[@"image_urls"] firstObject];
    if (!thumbURL) {
        cell.thumbnailImageView.image = nil;
    } else {
        [cell.activityIndicator startAnimating];
        
        __block NSIndexPath *indexPathBlock = indexPath;
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:thumbURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SearchTableViewCell *cell = (SearchTableViewCell *)[_tableView cellForRowAtIndexPath:indexPathBlock];
                if (cell) {
                    [cell.activityIndicator stopAnimating];
                    [UIView transitionWithView:cell.thumbnailImageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        cell.thumbnailImageView.image = [UIImage imageWithData:data];
                    } completion:nil];
                }
            });
        }] resume];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_gamesArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_canLoadMore) {
        return;
    }
    
    if (indexPath.row == [_gamesArray count] - 2) {
        [self searchAtOffset:[_gamesArray count]];
    }
}

- (void)processFavourite:(NSDictionary *)gameDic add:(BOOL)add image:(UIImage *)image {
    if (add) {
        NSMutableDictionary *cdGameDict = [NSMutableDictionary dictionaryWithDictionary:@{@"id": gameDic[@"_id"], @"title": gameDic[@"title"], @"platform": gameDic[@"platform"], @"condition": @"", @"favorite": @(YES)}];
        if (image) {
            NSURL *tmp = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] isDirectory:YES];
            NSString *tempFileName = [[NSUUID UUID] UUIDString];
            NSURL *tempFileURL = [tmp URLByAppendingPathComponent:tempFileName];
            if ([UIImageJPEGRepresentation(image, 1) writeToURL:tempFileURL atomically:YES]) {
                cdGameDict[@"imagePath"] = [tempFileURL lastPathComponent];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_ADDED" object:self userInfo:cdGameDict];
    } else {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Game"];
        request.predicate = [NSPredicate predicateWithFormat:@"gameID = %@", gameDic[@"_id"]];
        NSError *error;
        Game *game = [[[CoreDataController controller].managedObjectContext executeFetchRequest:request error:&error] firstObject];
        if (game) {
            [[CoreDataController controller] deleteGame:game];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *gameDic = _gamesArray[indexPath.row];
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell startStarUpdate];
    __block NSIndexPath *indexPathBlock = indexPath;
    BOOL add = ![gameDic[@"already_wanted"] boolValue];
    if (add) {
        [SMNetworking addGameToFavoritesWithID:gameDic[@"_id"] completion:^(BOOL success, NSString *errorString) {
            SearchTableViewCell *cell = (SearchTableViewCell *)[tableView cellForRowAtIndexPath:indexPathBlock];
            if (errorString) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            
            NSMutableDictionary *gameDic = _gamesArray[indexPathBlock.row];
            gameDic[@"already_wanted"] = @(errorString == nil);
            
            [cell finishStarUpdate:errorString == nil];
            
            if (!errorString) {
                [self processFavourite:gameDic add:YES image:cell.thumbnailImageView.image];
            }
        }];
    } else {
        [SMNetworking removeGameFromFavoritesWithID:gameDic[@"_id"] completion:^(BOOL success, NSString *errorString) {
            SearchTableViewCell *cell = (SearchTableViewCell *)[tableView cellForRowAtIndexPath:indexPathBlock];
            if (errorString) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            
            NSMutableDictionary *gameDic = _gamesArray[indexPathBlock.row];
            gameDic[@"already_wanted"] = @(errorString != nil);
            
            [cell finishStarUpdate:errorString != nil];
            if (!errorString) {
                [self processFavourite:gameDic add:NO image:nil];
            }
        }];
    }
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [_searchTask cancel];
    _gamesArray = [NSMutableArray array];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self searchAtOffset:0];
}

@end
