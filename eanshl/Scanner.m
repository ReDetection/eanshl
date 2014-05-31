//
//  Scanner.m
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

+ (void)load {
    [ScanditSDKBarcodePicker prepareWithAppKey:APIKEY];
    sharedInstance = [[Scanner alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.picker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:APIKEY];
        self.picker.overlayController.delegate = self;
    }
    return self;
}

+ (void)scanWithCompletion:(void (^)(NSString *code))block  {
    sharedInstance.completion = block;
    [sharedInstance.picker startScanning];
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode {
    NSLog(@"barcode %@", barcode);
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
}

@end
