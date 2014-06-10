//
// Created by sbuglakov on 6/10/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import <libextobjc/EXTScope.h>
#import "ScanSendViewModel.h"
#import "RDToshl.h"
#import "Barcode.h"
#import "ModelManager.h"
#import "Product.h"
#import "Price.h"
#import "RDToshlExpense.h"
#import "Secure.h"
#import "urls.h"

@interface ScanSendViewModel ()

@property(nonatomic, strong) ModelManager *modelManager;
@property(nonatomic, strong) Barcode *barcode;
@property(nonatomic, strong) RDToshl *toshlAPI;

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
    Barcode *barcode = [_modelManager barcodeWithEanString:code];
    if (barcode == nil) {
        barcode = [_modelManager createBarcodeWithString:code];
    }
    self.barcode = barcode;
}

- (void)setBarcode:(Barcode *)barcode {
    _barcode = barcode;
    self.eanLabelText = [NSString stringWithFormat:@"EAN: %@", barcode.barcode];
    Product *product = barcode.product;
    if (product != nil) {
        self.productName = product.name;
        if (product.prices.count > 0) {
            Price *price = product.prices.anyObject;
            self.moneyString = price.value;
        }

        self.tagsString= [[[product.tags valueForKeyPath:@"@distinctUnionOfObjects.name"] allObjects] componentsJoinedByString:@", "];
        [self.delegate triggerFieldsRenew];

    } else {
        [self.delegate triggerEnterNewProduct];
    }
}

- (NSArray *)tagsArrayFromText:(NSString *)tagsString {
    NSArray *array = [tagsString componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *tag in array) {
        NSString *trimmedTag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        [result addObject:trimmedTag];
    }
    return result;
}

- (void)sendToToshl {
    NSArray *tags = [self tagsArrayFromText:self.tagsString];
    if (_barcode.product == nil) {
        Product *product = [_modelManager createProductWithName:self.productName];
        Price *price = [_modelManager createPriceWithValue:self.moneyString];
        price.product = product;
        product.barcode = _barcode;

        for (NSString *tagString in tags) {
            ToshlTag *tag = [_modelManager findOrCreateTagWithName:tagString];
            [product addTagsObject:tag];
        }
    }

    [_modelManager save];


    RDToshlExpense *expense = [[RDToshlExpense alloc] init];
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
        _toshlAPI = [[RDToshl alloc] initWithClientID:TOSHL_CLIENT_ID secret:TOSHL_CLIENT_SECRET];
        [self.delegate toshlAuthCodeRequired:^(NSString *code) {
            [_toshlAPI authorizeWithCode:code redirectURI:REDIRECT_URL_STRING success:^{
                sendBlock();

            } fail:^(NSError *innerError) {
                _toshlAPI = nil;
                @strongify(self);
                [self.delegate displayError:innerError];
            }];
        }];

    } else {
        sendBlock();
    }
}

@end
