//
// Created by sbuglakov on 01/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ModelManager.h"
#import "Barcode.h"
#import "Product.h"
#import "Price.h"
#import "ToshlTag.h"


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

- (Barcode *)barcodeWithEanString:(NSString *)ean {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Barcode"];
    fetchRequest.fetchLimit = 1;
    //TODO ean with weight
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"barcode == %@", ean];
    fetchRequest.relationshipKeyPathsForPrefetching = @[@"product"];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil]; //TODO check for errors
    return results.count > 0 ? results[0] : nil;
}

- (ToshlTag *)tagWithName:(NSString *)name {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ToshlTag"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil]; //TODO check for errors
    return results.count > 0 ? results[0] : nil;
}

- (Barcode *)createBarcodeWithString:(NSString *)code {
    Barcode *result = [NSEntityDescription insertNewObjectForEntityForName:@"Barcode" inManagedObjectContext:self.managedObjectContext];
    result.barcode = code;
    return result;
}

- (Product *)createProductWithName:(NSString *)name {
    Product *result = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
    result.name = name;
    return result;
}

- (ToshlTag *)createTagWithName:(NSString *)name {
    ToshlTag *result = [NSEntityDescription insertNewObjectForEntityForName:@"ToshlTag" inManagedObjectContext:self.managedObjectContext];
    result.name = name;
    return result;
}

- (ToshlTag *)findOrCreateTagWithName:(NSString *)name {
    ToshlTag *tag = [self tagWithName:name];
    if (tag == nil) {
        tag = [self createTagWithName:name];
    }
    return tag;
}

- (Price *)createPriceWithValue:(NSString *)value {
    Price *result = [NSEntityDescription insertNewObjectForEntityForName:@"Price" inManagedObjectContext:self.managedObjectContext];
    result.value = value;
    return result;
}

- (void)save {
    [self.managedObjectContext save:nil]; //check for errors
}

@end
