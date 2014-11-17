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

@property (nonatomic, retain) NSString * destinationEmail;
@property (nonatomic, retain) NSNumber * destinationGameID;
@property (nonatomic, retain) NSString * originEmail;
@property (nonatomic, retain) NSNumber * originGameID;

@end
