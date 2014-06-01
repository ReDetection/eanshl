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
#import <ScanditSDK/ScanditSDKBarcodePicker.h>

@interface RDViewController () <UITextFieldDelegate>
@property(nonatomic, strong) ModelManager *modelManager;
@property(nonatomic, strong) Barcode *barcode;

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

- (IBAction)scanButtonPressed:(id)sender {
    [Scanner scanWithCompletion:^(NSString *code) {
        Barcode *barcode = [_modelManager barcodeWithEanString:code];
        if (barcode == nil) {
            barcode = [_modelManager createBarcodeWithString:code];
        }
        self.barcode = barcode;
    } fromViewController:self];
}

- (IBAction)sendToToshl:(id)sender {
    if (_barcode.product == nil) {
        Product *product = [_modelManager createProductWithName:_productNameTextField.text];
        Price *price = [_modelManager createPriceWithValue:_moneyTextField.text];
        price.product = product;
        product.barcode = _barcode;
    }

    [_modelManager save];
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
    } else {
        _productNameTextField.text = @"Введите имя продукта";
        [_productNameTextField becomeFirstResponder];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_productNameTextField selectAll:nil];
        });
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

@end
