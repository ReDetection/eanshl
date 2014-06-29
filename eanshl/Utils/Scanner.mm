//
//  Scanner.mm
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import "Scanner.h"

static Scanner *sharedInstance;

@interface Scanner ()
@property(nonatomic, copy) void (^completion)(NSString *);
@end

@implementation Scanner

+ (void)initialize {
    sharedInstance = [[Scanner alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)scanWithCompletion:(void (^)(NSString *code))block fromViewController:(UIViewController *)vc {
    sharedInstance.completion = block;
}

@end
