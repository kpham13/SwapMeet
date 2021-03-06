//
//  CoreDataController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "CoreDataController.h"

@implementation CoreDataController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGameAdded:) name:@"GAME_ADDED" object:nil];
    }
    return self;
}

+ (instancetype)controller {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "SM.SwapMeet" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SwapMeet" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SwapMeet.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Own methods

- (Game *)gameWithID:(NSString *)gameID {
    if (!gameID)
        return nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Game"];
    request.predicate = [NSPredicate predicateWithFormat:@"gameID = %@", gameID];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    return [results firstObject];
}

- (void) newGameAdded:(NSNotification *)notificaiton {
    NSLog(@"newGameAdded: %@", notificaiton.userInfo);
    Game *game = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    NSDictionary *info = notificaiton.userInfo;
    game.title = info[@"title"];
    game.condition = info[@"condition"];
    game.platform = info[@"platform"];
    game.gameID = info[@"id"];
    game.imagePath = info[@"imagePath"];
    NSNumber *favorite = info[@"favorite"];
    if (favorite) {
        game.isFavorited = favorite;
    }
    [self saveContext];
}

- (NSFetchedResultsController *) fetchUserGames:(NSInteger)segment {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Game"];
    request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor sortDescriptorWithKey:@"gameID" ascending:false] init], nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorited = %@", @(segment)];
    [request setPredicate:predicate];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    [controller performFetch: &error];
    if (!error) {
        return controller;
    } else {
        NSLog(@"Error in fetch request");
        return nil;
    }
}

// Add fetch game request after receive match

- (void) deleteGame:(Game *)game {
    NSString *gameID = game.gameID;
    BOOL inFavorites = [game.isFavorited boolValue];
    [self.managedObjectContext deleteObject:game];
    [self saveContext];
    if (inFavorites) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FAVORITE_DELETED" object:nil userInfo:@{@"id": gameID}];
    }
}

@end
