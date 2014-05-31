//
//  RDViewController.m
//  eanshl
//
//  Created by sbuglakov on 31/05/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import "RDViewController.h"
#import "Scanner.h"
#import <ScanditSDK/ScanditSDKBarcodePicker.h>

@interface RDViewController ()

@end

@implementation RDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButtonPressed:(id)sender {
    [Scanner scanWithCompletion:^(NSString *code) {
        NSLog(@"code");
    }];

}

@end
