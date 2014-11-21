//
//  SMNetworking.h
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMNetworkController.h"

extern NSString * const kSMDefaultsKeyToken;

@interface SMNetworking : SMNetworkController

+ (NSURLSessionDataTask *)matchesWithCompletion:(void(^)(NSArray *matches, NSString *errorString))completion;

+ (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                            andScreenName:(NSString *)screenName
                                zipNumber:(NSNumber *)zip
                               completion:(void(^)(BOOL successful, NSDictionary *profileDic, NSString *errorString))completion;

+ (NSURLSessionDataTask *)loginWithEmail:(NSString *)email
                             andPassword:(NSString *)password
                              completion:(void(^)(BOOL successful, NSDictionary *profileDic, NSString *errorString))completion;

+ (NSURLSessionDataTask *)setAvatarURLString:(NSString *)URLString
                                  completion:(void(^)(BOOL successful, NSString *errorString))completion;

+ (NSURLSessionDataTask *)gamesContaining:(NSString *)query
                              forPlatform:(NSString *)platform
                                 atOffset:(NSInteger)offset
                               completion:(void(^)(NSArray *objects, NSInteger itemsLeft, NSString *errorString))completion;

+ (NSURLSessionDataTask *)addGameToFavoritesWithID:(NSString *)gameID
                                        completion:(void(^)(BOOL success, NSString *errorString))completion;

+ (NSURLSessionDataTask *)removeGameFromFavoritesWithID:(NSString *)gameID
                                             completion:(void(^)(BOOL success, NSString *errorString))completion;

+ (NSURLSessionDataTask *)addNewGame:(NSDictionary *)gameDictionary
                          completion:(void(^)(NSString *gameID, NSString *errorString))completion;

+ (NSURLSessionDataTask *)deleteUserGameWithID:(NSString *)gameID
                                    completion:(void(^)(BOOL success, NSString *errorString))completion;

+ (NSURLSessionDataTask *)profileWithCompletion:(void(^)(NSDictionary *userDictionary, NSString *errorString))completion;

+ (void)invalidateToken;

@end
