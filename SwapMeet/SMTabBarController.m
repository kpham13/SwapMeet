//
//  SMTabBarController.m
//  SwapMeet
//
//  Created by Kevin Pham on 11/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMTabBarController.h"
#import "AppDelegate.h"

@interface SMTabBarController ()

@end

@implementation SMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.delegate = appDelegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
