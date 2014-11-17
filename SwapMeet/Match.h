//
//  Match.h
//  SwapMeet
//
//  Created by Kevin Pham on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Match : NSManagedObject

@property (nonatomic, retain) NSString * destination_email;
@property (nonatomic, retain) NSNumber * destination_game_id;
@property (nonatomic, retain) NSString * origin_email;
@property (nonatomic, retain) NSNumber * origin_game_id;

@end
