//
// Created by sbuglakov on 6/20/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "NSString+EANUtil.h"

@interface EANUtilIsGlobalTests : XCTestCase
@end

@implementation EANUtilIsGlobalTests

- (void)testGlobalEAN {
    XCTAssertTrue(@"4604567890123".isGlobalEAN);
    XCTAssertTrue(@"12345678".isGlobalEAN);
}

- (void)testLocalEAN {
    XCTAssertFalse(@"2104567890123".isGlobalEAN);
    XCTAssertFalse(@"2004567890123".isGlobalEAN);
}

@end
