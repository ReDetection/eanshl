//
// Created by sbuglakov on 6/11/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import "TagsUtil.h"


@implementation TagsUtil

+ (NSArray *)tagsArrayFromString:(NSString *)tagsString {
    NSArray *array = [tagsString componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *tag in array) {
        NSString *trimmedTag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        if (trimmedTag.length > 0) {
            [result addObject:trimmedTag];
        }
    }
    return result;
}

+ (NSString *)joinTags:(NSSet *)tags {
    return [[[tags valueForKeyPath:@"@distinctUnionOfObjects.name"] allObjects] componentsJoinedByString:@", "];
}

@end
