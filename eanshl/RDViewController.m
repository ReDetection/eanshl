//
//  RDViewController.m
//  eanshl
//
//  Created by sbuglakov on 31/05/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <ALAlertBanner/ALAlertBanner.h>
#import <libextobjc/EXTScope.h>
#import "RDViewController.h"
#import "Scanner.h"
#import "ModelManager.h"
#import "AuthorizeViewController.h"
#import "Secure.h"
#import "ScanSendViewModel.h"


@interface RDViewController () <UITextFieldDelegate, ScanSendViewModelDelegate>
@property (strong, nonatomic) ScanSendViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITextField *productNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *eanLabel;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@end

@implementation RDViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _viewModel = [[ScanSendViewModel alloc] initWithModelManager:[[ModelManager alloc] init]];
    _viewModel.delegate = self;
}

- (void)toshlAuthCodeRequired:(void (^)(NSString *code))callback {
    @weakify(self);
    [self performSegueWithIdentifier:@"authorize" sender: ^(NSString *authorization_code, NSError *error){
        if (authorization_code != nil) {
            callback(authorization_code);
        } else {
            @strongify(self);
            [self displayError:error];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    __weak AuthorizeViewController *dst = segue.destinationViewController;
    dst.clientID = TOSHL_CLIENT_ID;
    dst.scope = @"expenses:rw";
    @weakify(self);
    dst.completion = ^(NSString *authorization_code, NSError *error){
        if (authorization_code != nil) {
            [dst dismissViewControllerAnimated:YES completion:nil];
            if (sender != nil) {
                void (^op)(NSString *, NSError *) = sender;
                op(authorization_code, error);
            }

        } else {
             @strongify(self);
            [self displayError:error];
        }
    };
}

- (void)displayError:(NSError *)error {
    @weakify(self);
    void (^showMessageBlock)() = ^{
        NSLog(@"error occured: %@", error);
        @strongify(self);
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view.window style:ALAlertBannerStyleFailure position:ALAlertBannerPositionTop title:@"Error occured!" subtitle:error.localizedDescription];
        [banner show];
    };
    if (self.view.window != nil) {
        dispatch_async(dispatch_get_main_queue(), showMessageBlock);
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), showMessageBlock);
    }
}

- (void)displaySuccess:(NSString *)message {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view.window style:ALAlertBannerStyleSuccess position:ALAlertBannerPositionTop title:message];
        [banner show];
    });
}

- (IBAction)scanButtonPressed:(id)sender {
    [Scanner scanWithCompletion:^(NSString *code) {
        [_viewModel didScanBarcode:code];
    } fromViewController:self];
}

- (IBAction)sendToToshl:(id)sender {
    _moneyTextField.text = [_moneyTextField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];

    _viewModel.productName = _productNameTextField.text;
    _viewModel.tagsString = _tagsTextField.text;
    _viewModel.moneyString = _moneyTextField.text;
    [_viewModel sendToToshl];
}

- (void)triggerEnterNewProduct {
    _eanLabel.text = _viewModel.eanLabelText;
    _productNameTextField.text = @"Введите имя продукта";
    [_productNameTextField becomeFirstResponder];
}

- (void)triggerFieldsRenew {
    _productNameTextField.text = _viewModel.productName;
    _eanLabel.text = _viewModel.eanLabelText;
    _tagsTextField.text = _viewModel.tagsString;
    _moneyTextField.text = _viewModel.moneyString;
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
