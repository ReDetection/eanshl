//
// Created by sbuglakov on 6/20/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "NSString+EANUtil.h"

@interface EANUtilHasWeightTests : XCTestCase
@end

@implementation EANUtilHasWeightTests

- (void)testGlobalEAN {
    XCTAssertFalse(@"4604567890123".canHaveWeightInformation);
    XCTAssertFalse(@"12345678".canHaveWeightInformation);
}

- (void)testLocalEANWithoutWeight {
    XCTAssertFalse(@"2004567890123".isGlobalEAN);
}

- (void)testLocalEANWithWeight {
    XCTAssertFalse(@"2104567890123".isGlobalEAN);
}

@end
