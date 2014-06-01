//
//  Price.h
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Price : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSManagedObject *product;
@property (nonatomic, retain) NSManagedObject *store;

@end
