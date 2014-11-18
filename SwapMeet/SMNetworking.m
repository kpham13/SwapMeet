//
//  SMNetworking.m
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMNetworking.h"

@implementation SMNetworking

#pragma mark - Public Methods

+ (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                                zipNumber:(NSNumber *)zip
                               completion:(void(^)(NSString *token, NSString *errorString))completion
{
    NSString *errorString = nil;
    if (!email) {
        errorString = @"No email object";
    } else if (!password) {
        errorString = @"No password object";
    } else if (!zip) {
        errorString = @"No zip object";
    }
    
    if (errorString) {
        completion(nil, errorString);
        return nil;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email",
                            password, @"password",
                            zip, @"zip", nil];
    __block void(^completionBlock)(NSString *token, NSString *errorString) = completion;
    
    return [self performRequestWithURLPathString:@"user" method:@"POST" parameters:params acceptJSONResponse:YES sendBodyAsJSON:YES completion:^(NSData *data, NSString *errorString) {
        if (errorString) {                
            completionBlock(nil, errorString);
            return;
        }
        
        NSError *error;
        id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            completionBlock(nil, @"Couldn't parse response object");
            return;
        }
        
        NSString *token = JSONObject[@"jwt"];
        if (!token) {
            completionBlock(nil, [NSString stringWithFormat:@"No token.\n%@", JSONObject]);
            return;
        }
        
        completionBlock(token, nil);
    }];
}

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.baseURLString = @"https://cryptic-savannah-2534.herokuapp.com/api/";
    }
    return self;
}

@end
