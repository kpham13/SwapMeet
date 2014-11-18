//
//  SMNetworkController.h
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMNetworkController : NSObject

@property NSURLSession *session;
@property NSString *baseURLString;

+ (NSURLSessionDataTask *)performRequestWithURLPathString:(NSString *)URLPath
                                                   method:(NSString *)method
                                               parameters:(NSDictionary *)params
                                       acceptJSONResponse:(BOOL)acceptJSONResponse
                                           sendBodyAsJSON:(BOOL)bodyAsJSON
                                               completion:(void(^)(NSData *data, NSString *errorString))completion;

@end
