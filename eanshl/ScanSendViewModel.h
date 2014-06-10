//
// Created by sbuglakov on 6/10/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

@class ModelManager;

@protocol ScanSendViewModelDelegate <NSObject>
@required
- (void)toshlAuthCodeRequired:(void(^)(NSString *code))callback;
- (void)displayError:(NSError *)error;
- (void)displaySuccess:(NSString *)message;
- (void)triggerEnterNewProduct;
- (void)triggerFieldsRenew;
@end

@interface ScanSendViewModel : NSObject

@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong, readonly) NSString *eanLabelText;
@property (nonatomic, strong) NSString *tagsString;
@property (nonatomic, strong) NSString *moneyString;
@property (nonatomic, strong) NSString *storeName;

@property (nonatomic, weak) id<ScanSendViewModelDelegate> delegate;

- (id)initWithModelManager:(ModelManager *)modelManager;

- (void)didScanBarcode:(NSString *)barcode;
- (void)sendToToshl;

@end
