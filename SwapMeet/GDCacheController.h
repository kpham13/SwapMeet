//
//  GDCacheController.h
//  StackOverflowClient
//
//  Created by Alex G on 10.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDCacheController : NSObject

+ (id)objectForKey:(id)key;
+ (void)setObject:(id)object forKey:(id<NSCopying>)key ofLength:(NSUInteger)length;

@end
