//
//  SMAddGameViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMAddGameViewController.h"

@interface SMAddGameViewController ()

@property (strong, nonatomic) NSArray *consoles;

@end

@implementation SMAddGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consolePickerView.delegate = self;
    self.consolePickerView.dataSource = self;
    self.consoles = [[NSArray alloc] initWithObjects:@"Xbox One", @"PS4", @"Xbox 360", @"PS3", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.consoles count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.consoles objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 1;
}

@end
