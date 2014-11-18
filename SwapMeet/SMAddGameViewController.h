//
//  SMAddGameViewController.h
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMAddGameViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextView;
@property (weak, nonatomic) IBOutlet UIPickerView *consolePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *conditionPickerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

@end
