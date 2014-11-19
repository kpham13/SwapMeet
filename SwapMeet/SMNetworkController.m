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
    NSMutableArray *partsArray = [NSMutableArray array];
    for (id key in self) {
        if ([key isKindOfClass:[NSString class]]) {
            id value = self[key];
            if ([value isKindOfClass:[NSString class]]) {
                [partsArray addObject:[NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
            else if ([value isKindOfClass:[NSNumber class]]) {
                [partsArray addObject:[NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], value]];
            }
            else
                return nil;
        }
        else
            return nil;
    }
    
    return [partsArray componentsJoinedByString:@"&"];
}
@end

@interface NSMutableURLRequest (SMNetworkController)
@end
@implementation NSMutableURLRequest (SMNetworkController)
- (void)setBodyData:(NSData *)data bodyAsJSON:(BOOL)asJSON {
    self.HTTPBody = data;
    [self setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    NSString *format = [NSString stringWithFormat:@"%@; charset=utf-8", asJSON ? @"application/json" : @"application/x-www-form-urlencoded"];
    [self setValue:format forHTTPHeaderField:@"Content-Type"];
}
@end

#pragma mark - SMNetworkController

@interface SMNetworkController ()
@property NSMutableDictionary *HTTPHeaderParameters;
@end

@implementation SMNetworkController

#pragma mark - Public Methods

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (!self.HTTPHeaderParameters) {
        [self setHTTPHeaderParameters:[NSMutableDictionary dictionary]];
    }
    
    [self.HTTPHeaderParameters setObject:value forKey:field];
}

- (void)removeHTTPHeaderField:(NSString *)field {
    [self.HTTPHeaderParameters removeObjectForKey:field];
}

#pragma mark - Public Class Methods

+ (instancetype)controller {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

#pragma mark - Private Class Methods

+ (NSString *)processBadJSONResponse:(NSData *)data {
    if (!data)
        return nil;
    
    NSError *error;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        return [NSString stringWithFormat:@"\n%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
    }
    
    return [NSString stringWithFormat:@"\n%@", JSONObject];
}

+ (NSString *)processResponse:(NSURLResponse *)response error:(NSError *)error {
    if (error)
        return error.localizedDescription;
    
    NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
    NSString *errorString = nil;
    if (!((code >= 200) && (code < 500))) {
        if ((code >= 500) && (code < 600)) {
            errorString = @"Server error";
        } else {
            errorString = @"Unknown error";
        }
    }

    if (errorString)
        return [NSString stringWithFormat:@"%@: %ld", errorString, (long)code];
    
    return nil;
}

+ (NSURLSessionDataTask *)performRequestWithURLPathString:(NSString *)URLPath
                                                 method:(NSString *)method
                                             parameters:(NSDictionary *)params
                                     acceptJSONResponse:(BOOL)acceptJSONResponse
                                         sendBodyAsJSON:(BOOL)bodyAsJSON
                                             completion:(void(^)(NSData *data, NSString *errorString))completion {
    NSString *baseURLString = [[self controller] baseURLString];
    if (baseURLString) {
        return [self performRequestWithURLString:[baseURLString stringByAppendingPathComponent:URLPath]
                                          method:method parameters:params
                              acceptJSONResponse:acceptJSONResponse
                                  sendBodyAsJSON:bodyAsJSON
                                      completion:completion];
    }
    else {
        completion(nil, @"Base URL not set");
        return nil;
    }
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
    
    method = method ? [method uppercaseString] : @"GET";
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kSMNetworkingDefaultTimeout];
    if (!request) {
        completion(nil, [NSString stringWithFormat:@"Couldn't form the request: %@", URLString]);
        return nil;
    }
    
    request.HTTPMethod = method;
    NSDictionary *HTTPHeaderParameters = [[self controller] HTTPHeaderParameters];
    if (HTTPHeaderParameters) {
        for (NSString *key in HTTPHeaderParameters) {
            if ([key isKindOfClass:[NSString class]]) {
                NSString *value = HTTPHeaderParameters[key];
                if ([value isKindOfClass:[NSString class]]) {
                    [request setValue:value forHTTPHeaderField:key];
                } else {
                    completion(nil, [NSString stringWithFormat:@"HTTPHeaderParameters value is not a string: %@", value]);
                    return nil;
                }
            } else {
                completion(nil, [NSString stringWithFormat:@"HTTPHeaderParameters key is not a string: %@", key]);
                return nil;
            }
        }
    }
    
    if (acceptJSONResponse) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    if (params) {
        if (!bodyAsJSON) {
            NSString *encodedString = [params encodedStringForHTTPBody];
            if (encodedString) {
                request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", URLString, encodedString]];
            } else {
                completion(nil, [NSString stringWithFormat:@"Couldn't encode parameters: %@", params]);
                return nil;
            }
        }
        else if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"] || [method isEqualToString:@"PATCH"]) {
            NSError *error;
            NSData *bodyData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
            if (error) {
                completion(nil, [NSString stringWithFormat:@"Error building JSON object: %@", error.localizedDescription]);
                return nil;
            }
            
            if (!bodyData) {
                completion(nil, @"Couldn't create bodyData");
                return nil;
            }
            
            [request setBodyData:bodyData bodyAsJSON:bodyAsJSON];
        }
    }
    
    NSLog(@"URL: %@; method: %@", request.URL, request.HTTPMethod);
    
    NSURLSession *session = [[self controller] session];
    NSURLSessionDataTask *retVal = [session dataTaskWithRequest:request
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        __block NSString *errorString = [self processResponse:response error:error];
        __block void(^completionBlock)(NSData *data, NSString *errorString) = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorString) {
                NSString *serverResponseString = [self processBadJSONResponse:data];
                if (serverResponseString)
                    errorString = [errorString stringByAppendingString:serverResponseString];
                
                completionBlock(nil, errorString);
                return;
            }
            
            if (!data) {
                completionBlock(nil, @"Fatal error! Request succeed, but data is nil!");
                return;
            }
            
            completionBlock(data, nil);
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
