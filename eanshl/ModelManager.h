//
// Created by sbuglakov on 01/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//


@class Barcode;
@class Product;
@class Price;
@class ToshlTag;

@interface ModelManager : NSObject

- (Barcode *)barcodeWithEanString:(NSString *)ean;

- (Barcode *)createBarcodeWithString:(NSString *)code;
- (Product *)createProductWithName:(NSString *)name;
- (ToshlTag *)createTagWithName:(NSString *)name;
- (Price *)createPriceWithValue:(NSString *)value;

- (void)save;
@end
