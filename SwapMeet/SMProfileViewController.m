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

NSString * const kSMDefaultsKeyEmail = @"email";
NSString * const kSMDefaultsKeyScreenName = @"screenname";
NSString * const kSMDefaultsKeyZipCode = @"zipcode";
NSString * const kSMDefaultsKeyAvatarURL = @"avatar";

@interface SMProfileViewController ()

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSNumber *zipCode;
@property (strong, nonatomic) NSString *avatarURL;

@end

@implementation SMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.lookingForTextField.text = @"Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games, Games";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    
    NSString *zip = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyZipCode];
    //NSLog(@"%@", zip);
    
    if (!zip) {
        [SMNetworking profileWithCompletion:^(NSDictionary *userDictionary, NSString *errorString) {
            NSLog(@"SMNetworking");
            if (errorString != nil) {
                NSLog(@"Error: %@", errorString);
            } else {
                self.email = [userDictionary objectForKey:@"email"];
                self.screenName = [userDictionary objectForKey:@"screenname"];
                self.zipCode = [userDictionary objectForKey:@"zip"];
                self.avatarURL = [userDictionary objectForKey:@"avatar_url"];
                NSLog(@"1%@, %@", self.screenName, self.avatarURL);
                [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:kSMDefaultsKeyEmail];
                [[NSUserDefaults standardUserDefaults] setObject:self.screenName forKey:kSMDefaultsKeyScreenName];
                [[NSUserDefaults standardUserDefaults] setObject:self.zipCode forKey:kSMDefaultsKeyZipCode];
                [[NSUserDefaults standardUserDefaults] setObject:self.avatarURL forKey:kSMDefaultsKeyAvatarURL];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.screenName = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyScreenName];
                NSLog(@"2%@, %@", self.screenName, self.avatarURL);
            }
        }];
    } else {
        NSLog(@"User Defaults");
        self.email = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyEmail];
        self.screenName = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyScreenName];
        self.zipCode = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyZipCode];
        self.avatarURL = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyAvatarURL];
        NSLog(@"3%@, %@", self.screenName, self.avatarURL);
    }
    
    self.screenNameLabel.text = self.screenName;
    NSLog(@"4%@, %@", self.screenName, self.avatarURL);
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyScreenName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyZipCode];
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
