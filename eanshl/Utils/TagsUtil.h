//
// Created by sbuglakov on 6/11/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


@interface TagsUtil : NSObject

+ (NSArray *)tagsArrayFromString:(NSString *)tagsString;
+ (NSString *)joinTags:(NSSet *)tags;

@end
