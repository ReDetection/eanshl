//
// Created by sbuglakov on 01/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ModelManager.h"


@interface ModelManager ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation ModelManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

        self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

        [self addPersistentStores];

        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;

    }
    return self;
}


- (void)addPersistentStores {
    NSString *library = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *refDBPath = [library stringByAppendingPathComponent:@"db.sqlite"];
    NSURL *refDBURL = [NSURL fileURLWithPath:refDBPath];
    NSError *error = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:[refDBURL path]];
    if (!fileExists) {
        NSString *bundleDbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"db-2014.sqlite"];
        [fileManager copyItemAtPath:bundleDbPath toPath:refDBPath error:&error];
        NSLog(@"%@", error);
    }

    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:refDBURL
                                         options:     @{
                                                 NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},
                                                 NSMigratePersistentStoresAutomaticallyOption : @YES,
                                                 NSInferMappingModelAutomaticallyOption : @YES,
//                           NSSQLiteManualVacuumOption: @YES,
                                         }
                                           error:&error];

    //FIXME check for error

}



@end
