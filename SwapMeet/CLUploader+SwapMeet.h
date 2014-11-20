//
//  CLUploader+SwapMeet.h
//  SwapMeet
//
//  Created by Alex G on 19.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "CLUploader.h"

@interface CLUploader (SwapMeet)

+ (CLUploader *)uploaderWithDelegate:(id<CLUploaderDelegate>)delegate;

@end
