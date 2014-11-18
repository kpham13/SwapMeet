//
//  SMNetworking.m
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMNetworking.h"

@interface SMNetworking ()

@property NSString *token;

@end

@implementation SMNetworking

#pragma mark - Setters & Getters

@synthesize token = _token;

- (void)setToken:(NSString *)token {
    _token = token;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
}

- (NSString *)token {
    if (!_token) {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    }
    
    return _token;
}

#pragma mark - Public Methods

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
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email",
                            password, @"password",
                            zip, @"zip", nil];
    __block void(^completionBlock)(BOOL successful, NSString *errorString) = completion;
    
    return [self performRequestWithURLPathString:@"user" method:@"POST" parameters:params acceptJSONResponse:YES sendBodyAsJSON:YES completion:^(NSData *data, NSString *errorString)
    {
        NSString *token = nil;
        if (!errorString) {
            NSError *error;
            id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                errorString = [NSString stringWithFormat:@"Error converting JSON object: %@", error.localizedDescription];
            } else {
                token = JSONObject[@"jwt"];
                if (!token) {
                    errorString = [NSString stringWithFormat:@"No token.\n%@", JSONObject];
                } else {
                    [[self controller] setToken:token];
                    [[self controller] setValue:token forHTTPHeaderField:@"token"];
                }
            }
        }
        
        NSLog(@"Token: %@. Error: %@", token, errorString);
        
        completionBlock(token != nil, errorString);
    }];
}

+ (NSURLSessionDataTask *)JSONGamesAtOffset:(NSInteger)offset
                                 completion:(void(^)(NSArray *JSONObjects, NSInteger itemsLeft, NSString *errorString))completion
{
    // TODO: Implement
    return nil;
}

#pragma mark - Private Methods

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
                NSNumber *errorNumber = JSONDic[@"error"];
                if (!errorNumber) {
                    errorString = @"No 'error' object in response";
                } else {
                    itemsLeft = [JSONDic[@"items_left"] integerValue];
                    JSONObjects = JSONDic[@"items"];
                }
            }
        }
        
        completionBlock(JSONObjects, itemsLeft, errorString);
    }];
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
            [self setValue:token forHTTPHeaderField:@"token"];
        }
    }
    return self;
}

@end
