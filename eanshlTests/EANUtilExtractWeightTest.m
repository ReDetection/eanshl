//
// Created by sbuglakov on 6/20/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "NSString+EANUtil.h"

@interface EANUtilExtractWeightTest : XCTestCase
@end

@implementation EANUtilExtractWeightTest

- (void)test {
    XCTAssertEqualObjects([@"2034567123453" weight], @"12345");
}


@end
