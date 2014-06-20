//
// Created by sbuglakov on 6/20/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import "NSString+EANUtil.h"


@implementation NSString (EANUtil)

- (BOOL)isGlobalEAN {
    return !(self.length == 13 && [self characterAtIndex:0]=='2');
}

- (BOOL)canHaveWeightInformation {
    return (self.length == 13 && [self characterAtIndex:0]=='2' && [self characterAtIndex:1]!='0');
}

- (NSString *)addChecksum {
    NSUInteger lenght = self.length;
    NSUInteger accumulator = 0;
    for (NSUInteger i = 0; i<lenght; i++) {
        accumulator += ([self characterAtIndex:i] - '0') * ( i % 2 ? 3 : 1);
    }
    NSUInteger checksum = (NSUInteger) ((10 - (accumulator % 10)) % 10);
    return [self stringByAppendingFormat:@"%d",checksum];
}

- (NSString *)cutOutWeightInformation {
    return [[[self substringToIndex:7] stringByAppendingString:@"00000"] addChecksum];
}

@end
