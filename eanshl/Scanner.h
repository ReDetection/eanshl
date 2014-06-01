//
//  Scanner.h
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//


@interface Scanner : NSObject

+ (void)scanWithCompletion:(void (^)(NSString *code))block fromViewController:(UIViewController *)vc;

@end
