//
// Created by sbuglakov on 04/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


@class RDToshlUser;
@class RDToshlExpense;

@interface RDToshl : NSObject

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)secret;
- (void)authorizeWithCode:(NSString *)code redirectURI:(NSString *)redirectURI success:(void (^)(AFOAuthCredential *))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)authorizeWithCredential:(AFOAuthCredential *)credential success:(void (^)(AFOAuthCredential *credential))successBlock fail:(void (^)(NSError *error))failBlock;

- (void)userInfoWithSuccess:(void (^)(RDToshlUser *userInfo))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)expensesPageWithSuccess:(void (^)(NSArray *expenses))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)createExpense:(RDToshlExpense *)expense success:(void (^)())successBlock fail:(void (^)(NSError *error))failBlock;

@end
