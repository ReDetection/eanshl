//
//  Store.h
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Price;

@interface Store : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *products;
@property (nonatomic, retain) NSSet *prices;
@end

@interface Store (CoreDataGeneratedAccessors)

- (void)addProductsObject:(NSManagedObject *)value;
- (void)removeProductsObject:(NSManagedObject *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

- (void)addPricesObject:(Price *)value;
- (void)removePricesObject:(Price *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

@end
