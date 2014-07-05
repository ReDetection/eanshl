//
//  Scanner.m
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Scanner.h"


@interface ScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property(nonatomic, copy) void (^completion)(NSString *code);
@end

@implementation Scanner

+ (void)scanWithCompletion:(void (^)(NSString *code))block fromViewController:(UIViewController *)vc {
    ScanViewController *scanningController = [[ScanViewController alloc] init];
    scanningController.completion = block;
    [vc presentViewController:scanningController animated:YES completion:nil];
}

@end

@implementation ScanViewController {
    AVCaptureVideoPreviewLayer *prevLayer;
    AVCaptureSession *session;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;

    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }

    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];

    output.metadataObjectTypes = [output availableMetadataObjectTypes];

    prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    prevLayer.frame = self.view.bounds;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:prevLayer];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];

    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *) metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                [session stopRunning];
                self.completion(detectionString);
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
        }

//        if (detectionString != nil)
//        {
//            _label.text = detectionString;
//            break;
//        }
//        else
//            _label.text = @"(none)";
    }

//    _highlightView.frame = highlightViewRect;
}

@end
