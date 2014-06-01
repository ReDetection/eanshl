//
//  Product.h
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Barcode, Price, Store, ToshlTag;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * defaultPrice;
@property (nonatomic, retain) Barcode *barcode;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) Store *stores;
@property (nonatomic, retain) NSSet *prices;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addTagsObject:(ToshlTag *)value;
- (void)removeTagsObject:(ToshlTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addPricesObject:(Price *)value;
- (void)removePricesObject:(Price *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

@end
