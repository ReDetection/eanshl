//
// Created by sbuglakov on 04/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import <AFOAuth2Client/AFOAuth2Client.h>
#import <RestKit/RestKit.h>
#import "RDToshl.h"
#import "RDToshlUser.h"

static NSString *const TOSHL_AUTH_URL_STRING = @"https://toshl.com";
static NSString *const TOSHL_TOKEN_BY_AUTH_CODE_PATH = @"/oauth2/token";

static NSString *const TOSHL_API_URL_STRING = @"https://api.toshl.com";


@interface RDToshl ()
@property (nonatomic, strong) AFOAuth2Client *tokensClient;
@property (nonatomic, strong) AFOAuth2Client *apiClient;
@property (nonatomic, strong) RKObjectManager *restkit;
@end

@implementation RDToshl

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)secret {
    self = [super init];
    if (self) {
        _tokensClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:TOSHL_AUTH_URL_STRING] clientID:clientID secret:secret];
        _apiClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:TOSHL_API_URL_STRING] clientID:clientID secret:secret];
        _restkit = [[RKObjectManager alloc] initWithHTTPClient:_apiClient];
        [self registerMappings];
    }
    return self;
}

- (void)authorizeWithCode:(NSString *)code redirectURI:(NSString *)redirectURI success:(void (^)())successBlock fail:(void (^)(NSError *error))failBlock{
    [_tokensClient authenticateUsingOAuthWithPath:TOSHL_TOKEN_BY_AUTH_CODE_PATH code:code redirectURI:redirectURI success:^(AFOAuthCredential *credential) {
        [_apiClient setAuthorizationHeaderWithCredential:credential];
        if (successBlock != NULL) {
            successBlock();
        }

    } failure:^(NSError *error) {
        if (failBlock != NULL) {
            failBlock(error);
        }
    }];
}

- (void)userInfoWithSuccess:(void(^)(RDToshlUser *userInfo))successBlock fail:(void(^)(NSError *error))failBlock {
    [_restkit getObject:nil path:@"/me" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (successBlock != NULL) {
            successBlock(mappingResult.firstObject);
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failBlock != NULL) {
            failBlock(error);
        }
    }];
}

- (void)registerMappings {
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[RDToshlUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
            @"id" : @"identifier",
            @"email" : @"email",
            @"first_name" : @"firstname",
            @"last_name" : @"lastname",
    }];
    RKResponseDescriptor *userDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                        method:RKRequestMethodGET
                                                                                   pathPattern:@"/me"
                                                                                       keyPath:nil
                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    [_restkit addResponseDescriptor:userDescriptor];
}

@end
