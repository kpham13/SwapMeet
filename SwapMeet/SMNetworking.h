//
//  SMNetworking.h
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMNetworkController.h"

@interface SMNetworking : SMNetworkController

+ (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                                zipNumber:(NSNumber *)zip
                               completion:(void(^)(BOOL successful, NSString *errorString))completion;

@end
