//
//  SMAddGameViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMAddGameViewController.h"
#import "Game.h"

@interface SMAddGameViewController ()

@property (strong, nonatomic) NSArray *consoles;
@property (strong, nonatomic) NSArray *conditions;
@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) NSString *console;
@property (strong, nonatomic) NSString *condition;

@end

@implementation SMAddGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consolePickerView.delegate = self;
    self.consolePickerView.dataSource = self;
    self.consoles = [[NSArray alloc] initWithObjects:@"Xbox One", @"PS4", @"Xbox 360", @"PS3", nil];
    self.conditions = [[NSArray alloc] initWithObjects:@"Mint", @"Slightly Used", @"Noticably Used", @"At Least It Still Works...", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.consolePickerView) {
        return [self.consoles objectAtIndex:row];
    } else {
        return [self.conditions objectAtIndex:row];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.consolePickerView) {
        return [self.consoles count];
    } else {
        return [self.conditions count];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.consolePickerView) {
        self.console = [self.consoles objectAtIndex:row];
    } else {
        self.condition = [self.conditions objectAtIndex:row];
    }
}

- (IBAction)submitButtonClicked:(id)sender {
    self.game = [[Game alloc] init];
    self.game.title = self.titleTextView.text;
    self.game.platform = self.console;
    self.game.condition = self.condition;
    NSDictionary *gameDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"game", self.game, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_ADDED" object:self userInfo:gameDict];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
