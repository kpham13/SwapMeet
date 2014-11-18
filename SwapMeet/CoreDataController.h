//
//  CoreDataController.h
//  SwapMeet
//
//  Created by Reid Weber on 11/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Game.h"
#import "Match.h"

@interface CoreDataController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)controller;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
