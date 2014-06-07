//
// Created by sbuglakov on 6/7/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


@interface RDToshlExpense : NSObject

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSArray *tags;


@end
