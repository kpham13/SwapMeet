//
//  Game.h
//  SwapMeet
//
//  Created by Kevin Pham on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Game : NSManagedObject

@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * platform;
@property (nonatomic, retain) NSString * title;

@end
