//
//  SMProfileViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMProfileViewController.h"
#import "SMNetworking.h"

@interface SMProfileViewController ()

@end

@implementation SMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.lookingForTextField.text = @"Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games";
    
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"Temp Logout" message:@"Temporary way to logout." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SMNetworking invalidateToken];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        NSLog(@"%@", token);
    }];
    
    [logoutAlert addAction:cancelButton];
    [logoutAlert addAction:logoutAction];
    [self presentViewController:logoutAlert animated:true completion:nil];
    
//    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutUser:)];
//    [self.navigationItem setRightBarButtonItem:logoutButton animated:true];
}

- (void)viewDidAppear:(BOOL)animated {
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

- (void)logoutUser:(id)sender {
    [SMNetworking invalidateToken];
}

@end
