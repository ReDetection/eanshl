//
//  eanshlTests.m
//  eanshlTests
//
//  Created by sbuglakov on 31/05/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TagsUtil.h"

@interface TagsSplitTests : XCTestCase

@end

@implementation TagsSplitTests

- (void)testOneTag {
    NSArray *array = [TagsUtil tagsArrayFromString:@"one"];
    XCTAssertEqual(array.count, 1);
    XCTAssertEqualObjects(array[0], @"one");
}

- (void)testTwoTags {
    NSArray *array1 = [TagsUtil tagsArrayFromString:@"one, two"];
    XCTAssertEqual(array1.count, 2);
    XCTAssertEqualObjects(array1[0], @"one");
    XCTAssertEqualObjects(array1[1], @"two");
}

- (void)testTwoTagsWithMoreSpaces {
    NSArray *array2 = [TagsUtil tagsArrayFromString:@"    one , two  "];
    XCTAssertEqual(array2.count, 2);
    XCTAssertEqualObjects(array2[0], @"one");
    XCTAssertEqualObjects(array2[1], @"two");
}

- (void)testTwoTagsWithTwoCommas {
    NSArray *array2 = [TagsUtil tagsArrayFromString:@"one, , two"];
    XCTAssertEqual(array2.count, 2);
    XCTAssertEqualObjects(array2[0], @"one");
    XCTAssertEqualObjects(array2[1], @"two");
}

@end
