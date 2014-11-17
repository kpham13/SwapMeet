//
//  SMNetworkController.m
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMNetworkController.h"

const NSTimeInterval kSMNetworkingDefaultTimeout = 10;

#pragma mark - Helpers

@interface NSDictionary (SMNetworkController)
- (NSString *)encodedStringForHTTPBody;
@end
@implementation NSDictionary (SMNetworkController)
- (NSString *)encodedStringForHTTPBody {
    // TODO: Implement
    return @"";
}
@end

@interface NSMutableURLRequest (SMNetworkController)
@end
@implementation NSMutableURLRequest (SMNetworkController)
- (void)setBodyData:(NSData *)data {
    self.HTTPBody = data;
    [self setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [self setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
}
@end

#pragma mark - SMNetworkController

@interface SMNetworkController ()
@end

@implementation SMNetworkController

#pragma mark - Public Class Methods


#pragma mark - Private Class Methods

+ (instancetype)controller {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

//func performRequestWithURLString(URLString: String, method: String = "GET", parameters: [NSString: AnyObject]? = nil, acceptJSONResponse: Bool = false, sendBodyAsJSON: Bool = false, completion: (data: NSData!, errorString: String!) -> Void) {

//    
//    session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            if let errorString = self.processResponse(response, error: error) {
//                completion(data: data, errorString: errorString)
//                return
//            }
//            
//            if data == nil {
//                completion(data: nil, errorString: "Fatal error! Request succeed, but data is nil!")
//                return
//            }
//            
//            completion(data: data, errorString: nil)
//        })
//    }).resume()
//}


+ (NSString *)processResponse:(NSURLResponse *)response error:(NSError *)error {
    // TODO: Implement
    return @"";
}

+ (NSURLSessionDataTask *)performRequestWithURLString:(NSString *)URLString
                                               method:(NSString *)method
                                               parameters:(NSDictionary *)params
                                   acceptJSONResponse:(BOOL)acceptJSONResponse
                                       sendBodyAsJSON:(BOOL)bodyAsJSON
                                           completion:(void(^)(NSData *data, NSString *errorString))completion {
    if (!URLString) {
        completion(nil, @"Error. URLString cannot be nil.");
        return nil;
    }
    
    method = method? @"GET" : [method uppercaseString];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kSMNetworkingDefaultTimeout];
    if (!request) {
        // TODO: Error
    }
    
    request.HTTPMethod = method;
    if (acceptJSONResponse) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    if (params) {
        if ([method isEqualToString:@"GET"]) {
            NSString *encodedString = [params encodedStringForHTTPBody];
            if (encodedString) {
                request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", URLString, encodedString]];
            } else {
                // TODO: Error
            }
        } else if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"] || [method isEqualToString:@"PATCH"]) {
            NSData *bodyData = nil;
            if (bodyAsJSON) {
                NSError *error;
                bodyData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
                if (error) {
                    completion(nil, [NSString stringWithFormat:@"Error building JSON object: %@", error.localizedDescription]);
                    return nil;
                }
            }
            else {
                NSString *encodedString = [params encodedStringForHTTPBody];
                if (encodedString)
                    bodyData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (!bodyData) {
                completion(nil, @"Couln't create bodyData");
                return nil;
            }
            
            [request setBodyData:bodyData];
        }
    }
    
    NSURLSession *session = [[self controller] session];
    NSURLSessionDataTask *retVal = [session dataTaskWithRequest:request
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        __block NSString *errorString = [self processResponse:response error:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            //if (errorString)
        });
    }];
    
    [retVal resume];
    return retVal;
}

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.session = [NSURLSession sharedSession];
    }
    return self;
}

@end
