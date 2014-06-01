//
//  Barcode.h
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Product;

@interface Barcode : NSManagedObject

@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) Product *product;

@end
