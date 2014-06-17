//
//  Scanner.mm
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import "Scanner.h"
#import <ScanditSDK/ScanditSDKBarcodePicker.h>
#import <ScanditSDK/ScanditSDKOverlayController.h>

static NSString *const APIKEY = @"LNoWHujOEeOEQUAMsRwv1Db9NMx5kHKRf2Rv+jtGJ3g";

static Scanner *sharedInstance;

@interface Scanner () <ScanditSDKOverlayControllerDelegate>
@property(nonatomic, strong) ScanditSDKBarcodePicker *picker;
@property(nonatomic, copy) void (^completion)(NSString *);
@end

@implementation Scanner

+ (void)initialize {
    [ScanditSDKBarcodePicker prepareWithAppKey:APIKEY];
    sharedInstance = [[Scanner alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.picker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:APIKEY];
        self.picker.overlayController.delegate = self;
        [self.picker.overlayController showSearchBar:YES];
        [self.picker.overlayController showToolBar:YES];
    }
    return self;
}

+ (void)scanWithCompletion:(void (^)(NSString *code))block fromViewController:(UIViewController *)vc {
    sharedInstance.completion = block;
    sharedInstance.completion = block;
    [vc presentViewController:sharedInstance.picker animated:YES completion:^{
        [sharedInstance.picker startScanning];
    }];
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode {
    [self.picker stopScanning];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    self.completion(barcode[@"barcode"]);
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
    [self.picker stopScanning];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    self.completion(nil);
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
    [self.picker stopScanning];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    self.completion(text);
}

@end
