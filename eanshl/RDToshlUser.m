//
// Created by sbuglakov on 6/7/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import "RDToshlUser.h"

@implementation RDToshlUser

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@, %@>", NSStringFromClass(self.class), self.identifier, self.email];
}

@end
