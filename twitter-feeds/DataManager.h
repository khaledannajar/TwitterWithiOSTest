//
//  DataManager.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/17/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
