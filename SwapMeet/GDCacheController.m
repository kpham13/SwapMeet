//
//  GDCacheController.m
//  StackOverflowClient
//
//  Created by Alex G on 10.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "GDCacheController.h"

@implementation GDCacheController {
    NSMutableDictionary *cacheDic;
    NSMutableArray *array;
    NSUInteger size;
}

+ (instancetype)controller {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

+ (NSMutableDictionary *)dic {
    GDCacheController *c = [self controller];
    return c->cacheDic;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        cacheDic = [NSMutableDictionary dictionary];
        array = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Class Methods

+ (id)objectForKey:(id)key {
    return [[self dic] objectForKey:key];
}

+ (void)setObject:(id)object forKey:(id<NSCopying>)key ofLength:(NSUInteger)length {
    GDCacheController *c = [self controller];
    @synchronized(c) {
        if (c->size >= 1024 * 1024 * 20) {
            // If cache size is more than 20 MBs
            // remove older items in cache with summarized size
            // greater than or equal to 10 MBs
            
            NSUInteger minusSize = 0;
            NSUInteger expectedHalfSize = c->size / 2;
            NSUInteger i = 0;
            for (; i < [c->array count]; i++) {
                id dic = c->array[i];
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    minusSize += [dic[@"length"] unsignedIntegerValue];
                    
                    // Remove objects from main dictionary
                    [c->cacheDic removeObjectForKey:dic[@"key"]];
                    if (minusSize >= expectedHalfSize) {
                        break;
                    }
                }
            }
            
            // Update the array
            [c->array removeObjectsInRange:NSMakeRange(0, i + 1)];
            
            // Update the size
            c->size -= minusSize;
        }
        
        [c->cacheDic setObject:object forKey:key];
        [c->array addObject:@{@"key": key, @"length": @(length)}];
        c->size += length;
    }
}

@end
