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
#import "CLUploader+SwapMeet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+SwapMeet.h"

#pragma mark - Properties

@interface SMAddGameViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSArray *consoles;
@property (strong, nonatomic) NSArray *conditions;
@property (strong, nonatomic) NSString *console;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSMutableArray *photos;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSURLSessionDataTask *dataTask;
@property NSUInteger imageUploadsLeft;
@property NSMutableArray *remoteURLsArray;

@end

@implementation SMAddGameViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consolePickerView.delegate = self;
    self.consolePickerView.dataSource = self;
    self.consoles = [[NSArray alloc] initWithObjects:@"Xbox One", @"PS4", @"Xbox 360", @"PS3", nil];
    self.conditions = [[NSArray alloc] initWithObjects:@"Mint", @"Newish", @"Used", @"Still Works...", nil];
    self.photos = [NSMutableArray array];
    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
    self.imageView3.userInteractionEnabled = YES;
    
    _remoteURLsArray = [NSMutableArray array];
    
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
        
        [_activityIndicator startAnimating];
        self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
        
        // Save images to disc
        NSMutableArray *fileURLs = [NSMutableArray array];
        NSURL *tmp = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        for (UIImage *image in self.photos) {
            NSString *tempFileName = [[NSUUID UUID] UUIDString];
            NSURL *tempFileURL = [tmp URLByAppendingPathComponent:tempFileName];
            if ([UIImageJPEGRepresentation([image thumbnailImage], 0.8) writeToURL:tempFileURL atomically:NO]) {
                [fileURLs addObject:tempFileURL];
            }
        }
        
        // Upload images
        self.imageUploadsLeft = [fileURLs count];
        for (NSURL *url in fileURLs) {
            NSString *pathString = [url path];
            CLUploader *uploader = [CLUploader uploaderWithDelegate:nil];
            [uploader upload:pathString options:@{} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
                NSString *remoteURL = successResult[@"secure_url"];
                if (remoteURL) {
                    [_remoteURLsArray addObject:remoteURL];
                }
                
                self.imageUploadsLeft--;
                if (_imageUploadsLeft == 0) {
                    // Upload the actual game object
                    __block NSDictionary *gameDict = @{@"title": self.titleTextView.text, @"platform": self.console, @"condition": self.condition, @"image_urls": _remoteURLsArray};
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
                }
            } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
                //NSInteger percentsWritten = ((float)totalBytesWritten / (float)totalBytesExpectedToWrite) * 100;
            }];
        }
        
    } else {
        [self noTitleAlertController];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [_dataTask cancel];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)addPhotosButtonClicked:(id)sender {
    if ([self.photos count] >= 3) {
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
    [self setImages];
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.photos insertObject:[info objectForKey:UIImagePickerControllerOriginalImage] atIndex:[self.photos count]];
    [picker dismissViewControllerAnimated:true completion:nil];
    [self setImages];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - ImageView and Tap Gesture Methods

- (void)setImages {
    NSInteger index = 0;
    self.imageView1.image = nil;
    self.imageView2.image = nil;
    self.imageView3.image = nil;
    index++;
    for (UIImage *image in self.photos) {
        if (index == 1) {
            self.imageView1.image = image;
            UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(image1Tapped:)];
            [self.imageView1 addGestureRecognizer:touch];
            index++;
        } else if (index == 2) {
            self.imageView2.image = image;
            UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(image2Tapped:)];
            [self.imageView2 addGestureRecognizer:touch];
            index++;
        } else if (index == 3) {
            self.imageView3.image = image;
            UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(image3Tapped:)];
            [self.imageView3 addGestureRecognizer:touch];
            self.addImagesButton.enabled = NO;
        }
    }
}

- (void)addTouchGestures {
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] init];
    [self.imageView1 addGestureRecognizer:touch];
}

- (void) image1Tapped:(UITapGestureRecognizer *) recognizer {
    if (self.imageView1.image) {
        NSLog(@"Image Tapped");
        [self addSelectedImageAlert:self.imageView1];
    }
}

- (void) image2Tapped:(UITapGestureRecognizer *) recognizer {
    if (self.imageView2.image) {
        NSLog(@"Image Tapped");
        [self addSelectedImageAlert:self.imageView2];
    }
}

- (void) image3Tapped:(UITapGestureRecognizer *) recognizer {
    if (self.imageView3.image) {
        NSLog(@"Image Tapped");
        [self addSelectedImageAlert:self.imageView3];
    }
}

#pragma mark - Alert Controller Methods

- (void)addSelectedImageAlert: (UIImageView *) imageView {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"Choose An Option" message:@"Would you like to select this photo for your thumbnail? Or would you like to delete it?" preferredStyle:UIAlertControllerStyleAlert] init];
    UIAlertAction *thumbnailAction = [UIAlertAction actionWithTitle:@"Select As Thumbnail" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
        [self generateThumbnail:imageView.image];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSUInteger index = [self.photos indexOfObject:imageView.image];
        if (index != NSNotFound) {
            [self.photos removeObjectAtIndex:index];
            [self setImages];
            self.addImagesButton.enabled = YES;
        }
        
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:thumbnailAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)maxImagesReached {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"Too Many Photos" message:@"Sorry, You Can Only Add 3 Photos" preferredStyle:UIAlertControllerStyleAlert] init];
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
