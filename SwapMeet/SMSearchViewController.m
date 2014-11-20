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

@interface SMSearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *gamesArray;
@property (nonatomic) NSURLSessionDataTask *searchTask;
@property BOOL canLoadMore;
@property UIActivityIndicatorView *activityIndicator;

@end

@implementation SMSearchViewController

#pragma mark - Private Methods

- (void)searchAtOffset:(NSInteger)offset {
    _canLoadMore = NO;
    _searchTask = [SMNetworking gamesContaining:_searchBar.text forPlatform:nil atOffset:offset completion:^(NSArray *objects, NSInteger itemsLeft, NSString *errorString) {
        _canLoadMore = itemsLeft > 0;
        NSLog(@"Count: %ld. Items left: %ld", (long)[objects count], (long)itemsLeft);
        [_activityIndicator stopAnimating];
        if (errorString) {
            NSLog(@"%@", errorString);
            return;
        }
        
        [_gamesArray addObjectsFromArray:objects];
        [_tableView reloadData];
    }];
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
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_tableView.frame), CGRectGetMinY(_tableView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMinY(_tableView.frame))];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicator.color = [UIColor colorWithWhite:0.2 alpha:1];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view insertSubview:_activityIndicator aboveSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ADDED_FAVORITE" object:self userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegates Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL"];
    cell.mode = SearchTableViewCellModeSearch;
    [cell.activityIndicator stopAnimating];
    NSDictionary *gameDic = _gamesArray[indexPath.row];
    cell.titleLabel.text = gameDic[@"title"];
    cell.platformName.text = gameDic[@"platform"];
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

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [_searchTask cancel];
    _gamesArray = [NSMutableArray array];
    [_activityIndicator startAnimating];
    [self searchAtOffset:0];
}

@end
