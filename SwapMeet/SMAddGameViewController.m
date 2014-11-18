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
@property (strong, nonatomic) NSMutableArray *photos;

@end

@implementation SMAddGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consolePickerView.delegate = self;
    self.consolePickerView.dataSource = self;
    self.conditionPickerView.delegate = self;
    self.conditionPickerView.dataSource = self;
    self.consoles = [[NSArray alloc] initWithObjects:@"Xbox One", @"PS4", @"Xbox 360", @"PS3", nil];
    self.conditions = [[NSArray alloc] initWithObjects:@"Mint", @"Slightly Used", @"Noticably Used", @"At Least It Still Works...", nil];
    self.photos = [[NSMutableArray alloc] init];
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
    } else if (pickerView == self.conditionPickerView) {
        return [self.conditions objectAtIndex:row];
    } else {
        return @"ERROR";
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

- (IBAction)addPhotosButtonClicked:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self.photos addObject:image];
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.photos addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
    self.imageView1.image = [self.photos firstObject];
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

@end
