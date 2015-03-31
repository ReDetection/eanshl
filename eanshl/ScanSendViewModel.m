//
// Created by sbuglakov on 6/10/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import <AFOAuth2Client/AFOAuth2Client.h>
#import <libextobjc/EXTScope.h>
#import <RDToshlKit/RDToshlKit.h>
#import "ScanSendViewModel.h"
#import "Barcode.h"
#import "ModelManager.h"
#import "Product.h"
#import "Price.h"
#import "Secure.h"
#import "urls.h"
#import "TagsUtil.h"
#import "NSString+EANUtil.h"

static NSString *const KEYCHAIN_CREDENTIAL_IDENTIFIER = @"eanshl";

@interface ScanSendViewModel ()

@property(nonatomic, strong) ModelManager *modelManager;
@property(nonatomic, strong) Barcode *barcode;
@property(nonatomic, strong) NSString *weight;
@property(nonatomic, strong) RTKClient *toshlAPI;

@property (nonatomic, strong, readwrite) NSString *eanLabelText;
@end

@implementation ScanSendViewModel

- (id)initWithModelManager:(ModelManager *)modelManager {
    self = [super init];
    if (self) {
        _modelManager = modelManager;
    }
    return self;
}

- (void)didScanBarcode:(NSString *)code {
    if ([code canHaveWeightInformation]) {
        NSString *cuttedCode = [code cutOutWeightInformation];
        Barcode *barcode = [_modelManager barcodeWithEanString:code] ?: [_modelManager barcodeWithEanString:cuttedCode];
        if (barcode == nil) {
            @weakify(self);
            [self.delegate ifCuttedCode:cuttedCode shouldBeUsedInsteadOfFull:code withCompletion:^(BOOL cutted) {
                @strongify(self);
                _weight = cutted ? [code weight] : nil;
                self.barcode = [_modelManager createBarcodeWithString: cutted ? cuttedCode : code];
            }];

        } else {
            _weight = [barcode.barcode isEqual:cuttedCode] ? [code weight] : nil;
            self.barcode = barcode;
        }

    } else {
        Barcode *barcode = [_modelManager barcodeWithEanString:code];
        if (barcode == nil) {
            barcode = [_modelManager createBarcodeWithString:code];
        }
        _weight = nil;
        self.barcode = barcode;
    }
}

- (void)setBarcode:(Barcode *)barcode {
    _barcode = barcode;
    self.eanLabelText = [NSString stringWithFormat:@"EAN: %@", barcode.barcode];
    Product *product = barcode.product;
    if (product != nil) {
        self.productName = product.name;
        if (product.prices.count > 0) {
            Price *price = product.prices.anyObject;
            if (_weight == nil) {
                self.moneyString = price.value;
            } else {
                CGFloat weightComponent = [[@"0." stringByAppendingString:_weight] floatValue];
                self.moneyString = [NSString stringWithFormat:@"%0.2f", weightComponent * price.value.floatValue];
            }
        }

        self.tagsString = [TagsUtil joinTags:product.tags];
        [self.delegate triggerFieldsRenew];

    } else {
        [self.delegate triggerEnterNewProduct];
    }
}

- (void)sendToToshl {
    NSArray *tags = [TagsUtil tagsArrayFromString:self.tagsString];
    if (_barcode.product == nil) {
        _barcode.product = [_modelManager createProductWithName:self.productName];
    } else {
        _barcode.product.name = self.productName;
    }
    
    {
        NSString *moneyString;
        if (_weight == nil) {
            moneyString = self.moneyString;
        } else {
            CGFloat weightComponent = [[@"0." stringByAppendingString:_weight] floatValue];
            CGFloat normalizedPrice = [self.moneyString floatValue] / weightComponent;
            moneyString = [NSString stringWithFormat:@"%f", normalizedPrice];
        }
        Price *price = [_modelManager createPriceWithValue:moneyString];

        price.product = _barcode.product;
    }
    
    {
        Product *product = _barcode.product;
        [product removeTags:product.tags];
        for (NSString *tagString in tags) {
            ToshlTag *tag = [_modelManager findOrCreateTagWithName:tagString];
            [product addTagsObject:tag];
        }
    }

    [_modelManager save];


    RTKExpense *expense = [[RTKExpense alloc] init];
    expense.date = [NSDate date];
    expense.amount = @(self.moneyString.doubleValue);
    expense.currency = @"RUB";
    expense.tags = tags;
    expense.comment = self.productName;

    @weakify(self);
    void (^sendBlock)() = ^{
        [_toshlAPI createExpense:expense success:^{
            @strongify(self);
            [self.delegate displaySuccess:@"Expense sent to toshl.com"];
        } fail:^(NSError *error) {
            @strongify(self);
            [self.delegate displayError:error];
        }];
    };

    if (_toshlAPI == nil) {
        _toshlAPI = [[RTKClient alloc] initWithClientID:TOSHL_CLIENT_ID secret:TOSHL_CLIENT_SECRET];

        void (^askAuthCodeThenSendBlock)() = ^{
            [self.delegate toshlAuthCodeRequired:^(NSString *code) {
                [_toshlAPI authorizeWithCode:code redirectURI:REDIRECT_URL_STRING success: ^(AFOAuthCredential *newCredential){
                    [AFOAuthCredential storeCredential:newCredential withIdentifier:KEYCHAIN_CREDENTIAL_IDENTIFIER];
                    sendBlock();
                } fail:^(NSError *innerError) {
                    _toshlAPI = nil;
                    @strongify(self);
                    [self.delegate displayError:innerError];
                }];
            }];
        };

        AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:KEYCHAIN_CREDENTIAL_IDENTIFIER];
        if (credential != nil) {
            [_toshlAPI authorizeWithCredential:credential success:^(AFOAuthCredential *newCredential) {
                [AFOAuthCredential storeCredential:newCredential withIdentifier:KEYCHAIN_CREDENTIAL_IDENTIFIER];
                sendBlock();
            } fail:^(NSError *error) {
                askAuthCodeThenSendBlock();
            }];
        } else {
            askAuthCodeThenSendBlock();
        }
    } else {
        sendBlock();
    }
}

@end
