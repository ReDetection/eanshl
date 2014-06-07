//
//  AuthorizeViewController.h
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const redirectURLString;

@interface AuthorizeViewController : UIViewController

@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, copy) void (^completion)(NSString *authorization_code, NSError *error);
@end
