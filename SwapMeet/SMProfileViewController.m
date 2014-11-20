//
//  SMProfileViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMProfileViewController.h"
#import "SMNetworking.h"
#import "AppDelegate.h"

@interface SMProfileViewController ()

@end

@implementation SMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NetworkController method to retrieve user information & populate NSUserDefaults
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.lookingForTextField.text = @"Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games";
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

- (IBAction)logoutButton:(id)sender {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure you want to logout?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SMNetworking invalidateToken];
        
        //NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kSMDefaultsKeyToken];
        //NSLog(@"%@", token);
        
        // Switch to delegation in the future
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
        [tabBarController setSelectedIndex:0];
    }];
    
    [logoutAlert addAction:cancelButton];
    [logoutAlert addAction:logoutAction];
    [self presentViewController:logoutAlert animated:true completion:nil];
}

@end
