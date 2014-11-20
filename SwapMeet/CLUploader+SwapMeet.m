//
//  CLUploader+SwapMeet.m
//  SwapMeet
//
//  Created by Alex G on 19.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "CLUploader+SwapMeet.h"
#import "SMConstants.h"

@implementation CLUploader (SwapMeet)

+ (CLUploader *)uploaderWithDelegate:(id<CLUploaderDelegate>)delegate {
    CLCloudinary *cloudinary = [CLCloudinary new];
    [cloudinary.config setValue:kSMCLCloudname forKey:@"cloud_name"];
    [cloudinary.config setValue:kSMCLAPIKey forKey:@"api_key"];
    [cloudinary.config setValue:kSMCLAPISecret forKey:@"api_secret"];
    
    return [[CLUploader alloc] init:cloudinary delegate:delegate];
}

@end
