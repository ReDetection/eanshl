//
// Created by sbuglakov on 6/20/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


@interface NSString (EANUtil)

- (BOOL)isGlobalEAN;
- (BOOL)canHaveWeightInformation;
- (NSString *)addChecksum;
- (NSString *)cutOutWeightInformation;
- (NSString *)weight;

@end
