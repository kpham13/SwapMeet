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

@property (strong, nonatomic) NSMutableArray *games;

@end

@implementation SMSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate =self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GAME_CELL"];
    self.tableView.rowHeight = 150;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ADDED_FAVORITE" object:self userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL"];
    cell.titleLabel.text = @"Game Title";
    cell.imageView.backgroundColor = [UIColor blackColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"SEARCH CLICKED");
    [SMNetworking gamesContaining:self.searchBar.text forPlatform:nil atOffset:10 completion:^(NSArray *objects, NSInteger itemsLeft, NSString *errorString) {
        self.games = [[NSMutableArray alloc] initWithArray:objects];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }];
}

@end
