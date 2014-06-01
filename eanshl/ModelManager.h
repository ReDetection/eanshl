//
// Created by sbuglakov on 01/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


@class Barcode;

@interface ModelManager : NSObject

- (Barcode *)barcodeWithEanString:(NSString *)ean;

- (Barcode *)createBarcodeWithString:(NSString *)code;

- (void)save;
@end
