//
// Created by sbuglakov on 04/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


@class RDToshlUser;

@interface RDToshl : NSObject

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)secret;
- (void)authorizeWithCode:(NSString *)code redirectURI:(NSString *)redirectURI success:(void (^)())successBlock fail:(void (^)(NSError *error))failBlock;

- (void)userInfoWithSuccess:(void (^)(RDToshlUser *userInfo))successBlock fail:(void (^)(NSError *error))failBlock;

@end
