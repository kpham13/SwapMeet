//
//  SMAddGameViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMAddGameViewController.h"
#import "Game.h"
#import "SMNetworking.h"

#pragma mark - Properties

@interface SMAddGameViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSArray *consoles;
@property (strong, nonatomic) NSArray *conditions;
@property (strong, nonatomic) NSString *console;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSMutableArray *photos;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSURLSessionDataTask *dataTask;
@end

@implementation SMAddGameViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consolePickerView.delegate = self;
    self.consolePickerView.dataSource = self;
    self.consoles = [[NSArray alloc] initWithObjects:@"Xbox One", @"PS4", @"Xbox 360", @"PS3", nil];
    self.conditions = [[NSArray alloc] initWithObjects:@"Mint", @"Newish", @"Used", @"Still Works...", nil];
    self.photos = [[NSMutableArray alloc] init];
    self.imageView1.userInteractionEnabled = YES;
    [self addTouchGestures];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _activityIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicator.color = [UIColor colorWithWhite:0.2 alpha:1];
    [self.view addSubview:_activityIndicator];
    
    _titleTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PickerView Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [self.consoles objectAtIndex:row];
    } else if (component == 1) {
        return [self.conditions objectAtIndex:row];
    } else {
        return @"ERROR";
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.consoles count];
    } else if (component == 1) {
        return [self.conditions count];
    } else {
        return 0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.console = [self.consoles objectAtIndex:row];
    } else if (component == 1) {
        self.condition = [self.conditions objectAtIndex:row];
    }
}

#pragma mark - UIButton IBActions

- (IBAction)submitButtonClicked:(id)sender {
    if (![self.titleTextView.text isEqual: @""]) {
        if (!self.console) {
            self.console = [self.consoles firstObject];
        }
        if (!self.condition) {
            self.condition = [self.conditions firstObject];
        }
        if (self.imageView1.image) {
            [self generateThumbnail:self.imageView1.image];
        }
        __block NSDictionary *gameDict = @{@"title": self.titleTextView.text, @"platform": self.console, @"condition": self.condition};
        [_activityIndicator startAnimating];
        self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
        _dataTask = [SMNetworking addNewGame:gameDict completion:^(BOOL success, NSString *errorString) {
            [_activityIndicator stopAnimating];
            self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
            if (errorString) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_ADDED" object:self userInfo:gameDict];
            [self dismissViewControllerAnimated:true completion:nil];
        }];
    } else {
        [self noTitleAlertController];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [_dataTask cancel];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)addPhotosButtonClicked:(id)sender {
    if (self.imageView1.image) {
        [self maxImagesReached];
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:true completion:nil];
    }
}

#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self.photos addObject:image];
    self.imageView1.image = image;
    [picker dismissViewControllerAnimated:true completion:^{
        //[self addTouchGestures];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.photos insertObject:[info objectForKey:UIImagePickerControllerOriginalImage] atIndex:[self.photos count]];
    [picker dismissViewControllerAnimated:true completion:nil];
    self.imageView1.image = [info objectForKey:UIImagePickerControllerOriginalImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - ImageView and Tap Gesture Methods

- (void)addTouchGestures {
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(image1Tapped:)];
    [self.imageView1 addGestureRecognizer:touch];
}

- (void) image1Tapped:(UITapGestureRecognizer *) recognizer {
    if (self.imageView1.image) {
        NSLog(@"Image Tapped");
        [self addSelectedImageAlert:self.imageView1];
    }
}

#pragma mark - Alert Controller Methods

- (void)addSelectedImageAlert: (UIImageView *) imageView {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"Delete This Photo?" message: nil preferredStyle:UIAlertControllerStyleAlert] init];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSMutableArray *tempPhotos = [[NSMutableArray alloc] initWithArray:self.photos];
        for (UIImage *image in tempPhotos) {
            if (image == imageView.image) {
                [self.photos removeObject:image];
                self.imageView1.image = nil;
                self.addImagesButton.enabled = YES;
                break;
            }
        }
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)maxImagesReached {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"Too Many Photos" message:@"Sorry, You Can Only Add 1 Photo" preferredStyle:UIAlertControllerStyleAlert] init];
    UIAlertAction *alertAction = [[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }] init];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)noTitleAlertController {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"No Title!" message:@"You need at least a game title to continue" preferredStyle:UIAlertControllerStyleAlert] init];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction: action];
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Generate Thumbnail Method

- (UIImage *) generateThumbnail:(UIImage *) image {
    UIGraphicsBeginImageContext(CGSizeMake(75, 75));
    [image drawInRect:CGRectMake(0, 0, 75, 75)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    return thumbnail;
}

@end
