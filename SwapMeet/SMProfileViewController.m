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
#import "CLUploader+SwapMeet.h"
#import "UIImage+SwapMeet.h"
#import <MBProgressHUD/MBProgressHUD.h>

NSString * const kSMDefaultsKeyEmail = @"email";
NSString * const kSMDefaultsKeyScreenName = @"screenname";
NSString * const kSMDefaultsKeyZipCode = @"zipcode";
NSString * const kSMDefaultsKeyAvatarURL = @"avatar";

@interface SMProfileViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSNumber *zipCode;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) UIImage *avatarImage;

@end

@implementation SMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:touch];
    self.imageView.userInteractionEnabled = true;
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
                //NSLog(@"1%@, %@", self.screenName, self.avatarURL);
                [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:kSMDefaultsKeyEmail];
                [[NSUserDefaults standardUserDefaults] setObject:self.screenName forKey:kSMDefaultsKeyScreenName];
                [[NSUserDefaults standardUserDefaults] setObject:self.zipCode forKey:kSMDefaultsKeyZipCode];
                [[NSUserDefaults standardUserDefaults] setObject:self.avatarURL forKey:kSMDefaultsKeyAvatarURL];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self checkForAvatarImage];
                NSLog(@"checkforAvatarImage1");
                
                self.screenName = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyScreenName];
                //NSLog(@"2%@, %@", self.screenName, self.avatarURL);
            }
        }];
    } else {
        NSLog(@"User Defaults");
        self.email = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyEmail];
        self.screenName = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyScreenName];
        self.zipCode = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyZipCode];
        self.avatarURL = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyAvatarURL];
        
        [self checkForAvatarImage];
        NSLog(@"checkforAvatarimage");
        //NSLog(@"3%@, %@", self.screenName, self.avatarURL);
    }
    
    self.screenNameLabel.text = self.screenName;
    //NSLog(@"4%@, %@", self.screenName, self.avatarURL);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)logoutButton:(id)sender {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure you want to logout?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SMNetworking invalidateToken];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyScreenName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyZipCode];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyAvatarURL];
        self.avatarImage = nil;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
        [tabBarController setSelectedIndex:0];
    }];
    
    [logoutAlert addAction:cancelButton];
    [logoutAlert addAction:logoutAction];
    [self presentViewController:logoutAlert animated:true completion:nil];
}

- (void) imageTapped:(UITapGestureRecognizer *) gesture {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.avatarImage = image;
    self.imageView.image = self.avatarImage;
    NSLog(@"imagepicker set");
    
    [self generateThumbnail:self.imageView.image];
    
    // Save avatar image to disk
    NSString *fileURL;
    NSURL *temp = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] isDirectory:true];
    NSString *tempFileName = [[NSUUID UUID] UUIDString];
    NSURL *tempFileURL = [temp URLByAppendingPathComponent:tempFileName];
    if ([UIImageJPEGRepresentation([image thumbnailImage], 0.8) writeToURL:tempFileURL atomically:true]) {
        fileURL = [tempFileURL path];
    }
    
    // Upload images
    CLUploader *uploader = [CLUploader uploaderWithDelegate:nil];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Uploading image";
    hud.progress = 0.01;
            
    [uploader upload:fileURL options:@{} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
        NSString *remoteURL = successResult[@"secure_url"];
        [[NSUserDefaults standardUserDefaults] setObject:remoteURL forKey:kSMDefaultsKeyAvatarURL];
        
    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        NSLog(@"PROGRESS: %@", @(progress));
        hud.progress = progress;
        [hud hide:true];
    }];
    
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (UIImage *) generateThumbnail:(UIImage *) image {
    UIGraphicsBeginImageContext(CGSizeMake(75, 75));
    [image drawInRect:CGRectMake(0, 0, 75, 75)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    return thumbnail;
}

- (void)checkForAvatarImage {
    if (!self.avatarImage) {
        NSLog(@"Avatar image does not exist.");
        if (!self.avatarURL) {
            NSLog(@"No avatar URL saved.");
        } else {
            NSLog(@"Downloading image from saved URL in user defaults.");
            NSString *url = self.avatarURL;
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            self.avatarImage = image;
            self.imageView.image = self.avatarImage;
        }
    } else {
        NSLog(@"Avatar image does exist, setting image view.");
        //self.imageView.image = self.avatarImage;
    }
}

@end
