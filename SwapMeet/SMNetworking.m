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
        [self removeHTTPHeaderField:@"jwt"];
    }
}

- (NSString *)token {
    if (!_token) {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyToken];
    }
    
    return _token;
}

#pragma mark - Public Methods

+ (NSURLSessionDataTask *)matchesWithCompletion:(void(^)(NSArray *matches, NSString *errorString))completion {
    __block void(^completionBlock)(NSArray *matches, NSString *errorString) = completion;
    return [self performJSONRequestAtPath:@"matches" withMethod:@"GET" andParameters:nil sendBodyAsJSON:NO completion:^(NSDictionary *JSONDic, NSString *errorString) {
        if (errorString) {
            completionBlock(nil, errorString);
            return;
        }
        
        NSArray *items = JSONDic[@"items"];
        if (!items) {
            errorString = @"No 'items' object in response";
        }
        
        completionBlock(items, errorString);
    }];
}

+ (NSURLSessionDataTask *)addGameToFavoritesWithID:(NSString *)gameID
                                        completion:(void(^)(BOOL success, NSString *errorString))completion
{
    if (!gameID || [gameID isEqualToString:@""]) {
        completion(NO, @"gameID cannot be empty");
        return nil;
    }
    
    __block void(^completionBlock)(BOOL success, NSString *errorString) = completion;
    return [self performJSONRequestAtPath:@"games/wantsgames" withMethod:@"POST" andParameters:@{@"id": gameID} sendBodyAsJSON:YES completion:^(NSDictionary *JSONDic, NSString *errorString) {
        completionBlock(errorString == nil, errorString);
    }];
}

+ (NSURLSessionDataTask *)removeGameFromFavoritesWithID:(NSString *)gameID
                                             completion:(void(^)(BOOL success, NSString *errorString))completion {
    if (!gameID || [gameID isEqualToString:@""]) {
        completion(NO, @"gameID cannot be empty");
        return nil;
    }
    
    __block void(^completionBlock)(BOOL success, NSString *errorString) = completion;
    return [self performJSONRequestAtPath:@"games/wantsgames" withMethod:@"DELETE" andParameters:@{@"id": gameID} sendBodyAsJSON:YES completion:^(NSDictionary *JSONDic, NSString *errorString) {
        completionBlock(errorString == nil, errorString);
    }];
}

+ (NSURLSessionDataTask *)addNewGame:(NSDictionary *)gameDictionary
                          completion:(void(^)(NSString *gameID, NSString *errorString))completion {
    if (!gameDictionary) {
        completion(nil, @"Game dictionary can't be nil");
    }
    
    __block void(^completionBlock)(NSString *gameID, NSString *errorString) = completion;
    return [self performJSONRequestAtPath:@"games/hasgames" withMethod:@"POST" andParameters:gameDictionary sendBodyAsJSON:YES completion:^(NSDictionary *JSONDic, NSString *errorString) {
        NSString *gameID = [JSONDic valueForKeyPath:@"item._id"];
        if (!gameID && !errorString) {
            errorString = @"No game id at item._id path";
        }
        completionBlock(gameID, errorString);
    }];
}

+ (NSURLSessionDataTask *)deleteUserGameWithID:(NSString *)gameID
                                    completion:(void(^)(BOOL success, NSString *errorString))completion {
    if (!gameID || [gameID isEqualToString:@""]) {
        completion(NO, @"gameID cannot be empty");
        return nil;
    }
    
    __block void(^completionBlock)(BOOL success, NSString *errorString) = completion;
    return [self performJSONRequestAtPath:@"games/hasgames" withMethod:@"DELETE" andParameters:@{@"id": gameID} sendBodyAsJSON:YES completion:^(NSDictionary *JSONDic, NSString *errorString) {
        completionBlock(errorString == nil, errorString);
    }];
}

+ (void)invalidateToken {
    [[self controller] setToken:nil];
}

+ (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                            andScreenName:(NSString *)screenName
                                zipNumber:(NSNumber *)zip
                               completion:(void(^)(BOOL successful, NSDictionary *profileDic, NSString *errorString))completion
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
        completion(NO, nil, errorString);
        return nil;
    }
    
    NSDictionary *params = @{@"email": email, @"password": password, @"zip": zip, @"screenname": screenName};
    __block void(^completionBlock)(BOOL successful, NSDictionary *profileDic, NSString *errorString) = completion;
    
    return [self performRequestWithURLPathString:@"user" method:@"POST" parameters:params acceptJSONResponse:YES sendBodyAsJSON:NO completion:^(NSData *data, NSString *errorString)
    {
        NSDictionary *profileDic = nil;
        NSString *token = [self tokenByProcessingResponse:&errorString data:data profileDic:&profileDic];
        completionBlock(token != nil, profileDic, errorString);
    }];
}

+ (NSURLSessionDataTask *)loginWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                               completion:(void(^)(BOOL successful, NSDictionary *profileDic, NSString *errorString))completion
{
    NSString *errorString = nil;
    if (!email) {
        errorString = @"No 'email' object";
    } else if (!password) {
        errorString = @"No 'password' object";
    }
    
    if (errorString) {
        completion(NO, nil, errorString);
        return nil;
    }
    
    NSDictionary *params = @{@"email": email, @"password": password};
    __block void(^completionBlock)(BOOL successful, NSDictionary *profileDic, NSString *errorString) = completion;
    
    return [self performRequestWithURLPathString:@"user" method:@"GET" parameters:params acceptJSONResponse:YES sendBodyAsJSON:NO completion:^(NSData *data, NSString *errorString)
            {
                NSDictionary *profileDic = nil;
                NSString *token = [self tokenByProcessingResponse:&errorString data:data profileDic:&profileDic];
                completionBlock(token != nil, profileDic, errorString);
            }];
}

+ (NSURLSessionDataTask *)setAvatarURLString:(NSString *)URLString
                                  completion:(void(^)(BOOL successful, NSString *errorString))completion {
    if (!URLString) {
        completion(NO, @"URLString can not be nil");
        return nil;
    }
    __block void(^completionBlock)(BOOL successful, NSString *errorString) = completion;
    
    return [self performJSONRequestAtPath:@"user" withMethod:@"PUT" andParameters:@{@"avatar_url": URLString} sendBodyAsJSON:YES completion:^(NSDictionary *JSONDic, NSString *errorString) {
        completionBlock(errorString == nil, errorString);
    }];
}

+ (NSURLSessionDataTask *)profileWithCompletion:(void(^)(NSDictionary *userDictionary, NSString *errorString))completion {
    __block void(^completionBlock)(NSDictionary *userDictionary, NSString *errorString) = completion;
    return [self performJSONRequestAtPath:@"user/myprofile" withMethod:@"GET" andParameters:nil sendBodyAsJSON:NO completion:^(NSDictionary *JSONDic, NSString *errorString) {
        NSDictionary *userDictionary = nil;
        if (!errorString) {
            userDictionary = JSONDic[@"profile"];
            if (!userDictionary) {
                errorString = @"No 'profile' key in response";
            }
        }
        completionBlock(userDictionary, errorString);
    }];
}

+ (NSURLSessionDataTask *)gamesContaining:(NSString *)query
                              forPlatform:(NSString *)platform
                                 atOffset:(NSInteger)offset
                               completion:(void(^)(NSArray *objects, NSInteger itemsLeft, NSString *errorString))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (query) {
        params[@"q"] = query;
    }
    
    if (platform) {
        params[@"p"] = platform;
    }
    
    if (offset > 0) {
        params[@"s"] = @(offset);
    }
    
    if ([params count] == 0) {
        params = nil;
    }
    
    __block void(^completionBlock)(NSArray *objects, NSInteger itemsLeft, NSString *errorString) = completion;
    return [self performJSONRequestAtPath:@"wantsgames" withMethod:@"GET" andParameters:params sendBodyAsJSON:NO completion:^(NSDictionary *JSONDic, NSString *errorString) {
        NSInteger itemsLeft = 0;
        NSMutableArray *objects = nil;
        if (!errorString) {
            itemsLeft = [JSONDic[@"items_left"] integerValue];
            NSArray *tmpObjects = JSONDic[@"items"];
            if (tmpObjects) {
                objects = [NSMutableArray array];
                for (NSDictionary *dic in tmpObjects) {
                    [objects addObject:[NSMutableDictionary dictionaryWithDictionary:dic]];
                }
            }
        }
        
        completionBlock(objects, itemsLeft, errorString);        
    }];
}

#pragma mark - Private Methods

+ (NSString *)tokenByProcessingResponse:(NSString **)errorString_p data:(NSData *)data profileDic:(NSDictionary **)profileDic_p
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
                
                *profileDic_p = JSONObject[@"profile"];
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
                                    completion:(void(^)(NSDictionary *JSONDic, NSString *errorString))completion
{
    __block void(^completionBlock)(NSDictionary *JSONDic, NSString *errorString) = completion;
    return [self performRequestWithURLPathString:path method:method parameters:params acceptJSONResponse:YES sendBodyAsJSON:bodyAsJSON completion:^(NSData *data, NSString *errorString) {
        NSDictionary *JSONDic = nil;
        if (!errorString) {
            NSError *error;
            JSONDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                errorString = [NSString stringWithFormat:@"Object is not JSON. %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            } else {
                errorString = [self checkJSONResponse:JSONDic];
                if (errorString) {
                    JSONDic = nil;
                }
            }
        }
        
        completionBlock(JSONDic, errorString);
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
            case 8:
                retVal = @"Game already in favorites";
                break;
            case 9:
                retVal = @"Game not found in user's list";
                break;
            case 10:
                retVal = @"Invalid game id";
                break;
            case 11:
                retVal = @"Item must have title and platform";
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
