//
// Created by sbuglakov on 6/20/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "NSString+EANUtil.h"

@interface EANUtilAddChecksumTests : XCTestCase
@end

@implementation EANUtilAddChecksumTests

- (void)testWhenChecksumIsZero {
    XCTAssertEqualObjects([@"224230900000" addChecksum], @"2242309000000");
}

- (void)testWhenChecksumIsNotZero {
    XCTAssertEqualObjects([@"224439900000" addChecksum], @"2244399000007");
    XCTAssertEqualObjects([@"460601608135" addChecksum], @"4606016081352");
}

@end
