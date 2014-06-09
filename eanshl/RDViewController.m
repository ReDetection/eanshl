//
//  RDViewController.m
//  eanshl
//
//  Created by sbuglakov on 31/05/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import "RDViewController.h"
#import "Scanner.h"
#import "ModelManager.h"
#import "Product.h"
#import "Barcode.h"
#import "Price.h"
#import "AuthorizeViewController.h"
#import "Secure.h"
#import "RDToshl.h"
#import "RDToshlExpense.h"
#import "ToshlTag.h"
#import "ALAlertBanner.h"

@interface RDViewController () <UITextFieldDelegate>
@property(nonatomic, strong) ModelManager *modelManager;
@property(nonatomic, strong) Barcode *barcode;
@property(nonatomic, strong) RDToshl *toshlAPI;

@property (weak, nonatomic) IBOutlet UITextField *productNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *eanLabel;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@end

@implementation RDViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _modelManager = [[ModelManager alloc] init];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    __weak AuthorizeViewController *dst = segue.destinationViewController;
    dst.clientID = TOSHL_CLIENT_ID;
    dst.scope = @"expenses:rw";
    dst.completion = ^(NSString *authorization_code, NSError *error){
        if (authorization_code != nil) {
            [dst dismissViewControllerAnimated:YES completion:nil];
            [_toshlAPI authorizeWithCode:authorization_code redirectURI:redirectURLString success:^{
                if (sender != nil) {
                    void (^op)() = sender;
                    op();
                }

            } fail:^(NSError *error) {
                _toshlAPI = nil;
                [self displayError:error];
            }];
        } else {
            [self displayError:error];
        }
    };
}

- (void)displayError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"error occured: %@", error);
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view.window style:ALAlertBannerStyleFailure position:ALAlertBannerPositionTop title:@"Error occured!" subtitle:error.localizedDescription];
        [banner show];
    });
}

- (void)displaySuccess:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view.window style:ALAlertBannerStyleSuccess position:ALAlertBannerPositionTop title:message];
        [banner show];
    });
}

- (IBAction)scanButtonPressed:(id)sender {
    [Scanner scanWithCompletion:^(NSString *code) {
        Barcode *barcode = [_modelManager barcodeWithEanString:code];
        if (barcode == nil) {
            barcode = [_modelManager createBarcodeWithString:code];
        }
        self.barcode = barcode;
    } fromViewController:self];
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

- (IBAction)sendToToshl:(id)sender {
    _moneyTextField.text = [_moneyTextField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];

    NSArray *tags = [self tagsArrayFromText:_tagsTextField.text];
    if (_barcode.product == nil) {
        Product *product = [_modelManager createProductWithName:_productNameTextField.text];
        Price *price = [_modelManager createPriceWithValue:_moneyTextField.text];
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
    expense.amount = @(_moneyTextField.text.doubleValue);
    expense.currency = @"RUB";
    expense.tags = tags;
    expense.comment = _productNameTextField.text;
    void (^sendBlock)() = ^{
        [_toshlAPI createExpense:expense success:^{
            [self displaySuccess:@"Expense sent to toshl.com"];
        } fail:^(NSError *error) {
            [self displayError:error];
        }];
    };

    if (_toshlAPI == nil) {
        _toshlAPI = [[RDToshl alloc] initWithClientID:TOSHL_CLIENT_ID secret:TOSHL_CLIENT_SECRET];
        [self performSegueWithIdentifier:@"authorize" sender:sendBlock];

    } else {
        sendBlock();
    }
}

- (void)setBarcode:(Barcode *)barcode {
    _barcode = barcode;
    _eanLabel.text = [NSString stringWithFormat:@"EAN: %@", barcode.barcode];
    Product *product = barcode.product;
    if (product != nil) {
        _productNameTextField.text = product.name;
        if (product.prices.count > 0) {
            Price *price = product.prices.anyObject;
            _moneyTextField.text = price.value;
        }

        _tagsTextField.text = [[[product.tags valueForKeyPath:@"@distinctUnionOfObjects.name"] allObjects] componentsJoinedByString:@", "];

    } else {
        _productNameTextField.text = @"Введите имя продукта";
        [_productNameTextField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _productNameTextField) {
        [_tagsTextField becomeFirstResponder];
    } else if (textField == _tagsTextField) {
        [_moneyTextField becomeFirstResponder];
    } else if (textField == _moneyTextField) {
        [_moneyTextField resignFirstResponder];
        [self sendToToshl:nil];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([textField isFirstResponder]) {
            [textField selectAll:nil];
        }
    });
}

@end
