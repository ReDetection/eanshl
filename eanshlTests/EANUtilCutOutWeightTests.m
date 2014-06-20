//
// Created by sbuglakov on 6/20/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "NSString+EANUtil.h"

@interface EANUtilCutOutWeightTests : XCTestCase
@end

@implementation EANUtilCutOutWeightTests

- (void)test {
    XCTAssertEqualObjects([@"2242309000000" cutOutWeightInformation], @"2242309000000");
    XCTAssertEqualObjects([@"2244399003558" cutOutWeightInformation], @"2244399000007");
}


@end
