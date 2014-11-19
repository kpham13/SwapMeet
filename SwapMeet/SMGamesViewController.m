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

@interface SMGamesViewController ()

@property (strong, nonatomic) NSMutableArray *myGames;

@end

@implementation SMGamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:@"ADDED_FAVORITE" object:nil];
    self.myGames = [[CoreDataController controller] fetchUserGames];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    self.myGames = [[CoreDataController controller] fetchUserGames];
    [self.tableView reloadData];
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
    return [self.myGames count];
}

- (IBAction)addButtonClicked:(id)sender {
    SMAddGameViewController *addGameVC = [[SMAddGameViewController alloc] initWithNibName:@"SMAddGameViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:addGameVC animated:YES completion:nil];
    
    NSLog(@"Add Button Clicked");
}

- (void) favoriteAdded:(NSNotification *)notification {
    NSLog(@"Favorite Added");
}

@end
