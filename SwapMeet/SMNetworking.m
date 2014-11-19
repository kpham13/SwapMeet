//
//  SMNetworking.m
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMNetworking.h"

NSString * const kSMDefaultsKeyToken = @"token";

@interface SMNetworking ()

@property NSString *token;

@end

@implementation SMNetworking

#pragma mark - Setters & Getters

@synthesize token = _token;

- (void)setToken:(NSString *)token {
    _token = token;
    if (token) {
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:kSMDefaultsKeyToken];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyToken];
    }
}

- (NSString *)token {
    if (!_token) {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyToken];
    }
    
    return _token;
}

#pragma mark - Public Methods

+ (void)invalidateToken {
    [[self controller] setToken:nil];
}

+ (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                                zipNumber:(NSNumber *)zip
                               completion:(void(^)(BOOL successful, NSString *errorString))completion
{
    NSString *errorString = nil;
    if (!email) {
        errorString = @"No 'email' object";
    } else if (!password) {
        errorString = @"No 'password' object";
    } else if (!zip) {
        errorString = @"No 'zip' object";
    }
    
    if (errorString) {
        completion(NO, errorString);
        return nil;
    }
    
    NSDictionary *params = @{@"email": email, @"password": password, @"zip": zip};
    __block void(^completionBlock)(BOOL successful, NSString *errorString) = completion;
    
    return [self performRequestWithURLPathString:@"user" method:@"POST" parameters:params acceptJSONResponse:YES sendBodyAsJSON:NO completion:^(NSData *data, NSString *errorString)
    {
        NSString *token = [self tokenByProcessingResponse:&errorString data:data];
        completionBlock(token != nil, errorString);
    }];
}

+ (NSURLSessionDataTask *)loginWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                               completion:(void(^)(BOOL successful, NSString *errorString))completion
{
    NSString *errorString = nil;
    if (!email) {
        errorString = @"No 'email' object";
    } else if (!password) {
        errorString = @"No 'password' object";
    }
    
    if (errorString) {
        completion(NO, errorString);
        return nil;
    }
    
    NSDictionary *params = @{@"email": email, @"password": password};
    __block void(^completionBlock)(BOOL successful, NSString *errorString) = completion;
    
    return [self performRequestWithURLPathString:@"user" method:@"GET" parameters:params acceptJSONResponse:YES sendBodyAsJSON:NO completion:^(NSData *data, NSString *errorString)
            {
                NSString *token = [self tokenByProcessingResponse:&errorString data:data];
                completionBlock(token != nil, errorString);
            }];
}

+ (NSURLSessionDataTask *)gamesContaining:(NSString *)query
                              forPlatform:(NSString *)platform
                                 atOffset:(NSInteger)offset
                               completion:(void(^)(NSArray *objects, NSInteger itemsLeft, NSString *errorString))completion
{
    if (!query || [query isEqualToString:@""]) {
        completion(nil, 0, @"Query string can not be empty!");
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"q": query}];
    if (platform) {
        params[@"p"] = platform;
    }
    
    if (offset > 0) {
        params[@"s"] = @(offset);
    }
    
    return [self performJSONRequestAtPath:@"wantsgames" withMethod:@"GET" andParameters:params sendBodyAsJSON:NO completion:completion];
}

#pragma mark - Private Methods

+ (NSString *)tokenByProcessingResponse:(NSString **)errorString_p data:(NSData *)data
{
    NSString *token = nil;
    if (!(*errorString_p)) {
        NSError *error;
        id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            *errorString_p = [NSString stringWithFormat:@"Error converting JSON object: %@. %@", error.localizedDescription, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        } else {
            *errorString_p = [self checkJSONResponse:JSONObject];
            if (!(*errorString_p)) {
                token = JSONObject[@"jwt"];
                if (!token) {
                    *errorString_p = [NSString stringWithFormat:@"No token.\n%@", JSONObject];
                } else {
                    [[self controller] setToken:token];
                    [[self controller] setValue:token forHTTPHeaderField:@"jwt"];
                }
            }
        }
    }
    
    NSLog(@"Token: %@. Error: %@", token, *errorString_p);
    return token;
}

+ (NSURLSessionDataTask *)performJSONRequestAtPath:(NSString *)path
                                    withMethod:(NSString *)method
                                 andParameters:(NSDictionary *)params
                                sendBodyAsJSON:(BOOL)bodyAsJSON
                                    completion:(void(^)(NSArray *JSONObjects, NSInteger itemsLeft, NSString *errorString))completion
{
    __block void(^completionBlock)(NSArray *JSONObjects, NSInteger itemsLeft, NSString *errorString) = completion;
    return [self performRequestWithURLPathString:path method:method parameters:params acceptJSONResponse:YES sendBodyAsJSON:bodyAsJSON completion:^(NSData *data, NSString *errorString) {
        NSArray *JSONObjects = 0;
        NSInteger itemsLeft = 0;
        if (!errorString) {
            NSError *error;
            NSDictionary *JSONDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                errorString = [NSString stringWithFormat:@"Error converting JSON object: %@", error.localizedDescription];
            } else {
                errorString = [self checkJSONResponse:JSONDic];
                if (!errorString) {
                    itemsLeft = [JSONDic[@"items_left"] integerValue];
                    JSONObjects = JSONDic[@"items"];
                }
            }
        }
        
        completionBlock(JSONObjects, itemsLeft, errorString);
    }];
}

+ (NSString *)checkJSONResponse:(NSDictionary *)JSONDic {
    NSString *retVal = nil;
    NSNumber *errorNumber = JSONDic[@"error"];
    if (!errorNumber) {
        retVal = @"No 'error' object in response";
    } else {
        NSInteger err = [errorNumber integerValue];
        switch (err) {
            case 0:
                break;
            case 1:
                retVal = @"Fatal server error";
                break;
            case 2:
                retVal = @"Cannot create user";
                break;
            case 3:
                retVal = @"email and password cannot be the same";
                break;
            case 4:
                retVal = @"Invalid password";
                break;
            case 5:
                retVal = @"No data to return";
                break;
            case 6:
                retVal = @"No user by that name";
                break;
            case 7:
                retVal = @"Access denied";
                break;
                
            default:
                retVal = @"Unknown server error";
                break;
        }
    }
    
    return retVal;
}

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.baseURLString = @"https://cryptic-savannah-2534.herokuapp.com/api/";
        [self setValue:@"someFancyKey" forHTTPHeaderField:@"key"];
        NSString *token = [self token];
        if (token) {
            [self setValue:token forHTTPHeaderField:@"jwt"];
        }
    }
    return self;
}

@end
