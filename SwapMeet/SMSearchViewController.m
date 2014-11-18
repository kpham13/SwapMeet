//
//  SMSearchViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSearchViewController.h"

@interface SMSearchViewController ()

@end

@implementation SMSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate =self;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ADDED_FAVORITE" object:self userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SEARCH_CELL"];
    cell.backgroundColor = [UIColor blueColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"SEARCH CLICKED");
}

@end
