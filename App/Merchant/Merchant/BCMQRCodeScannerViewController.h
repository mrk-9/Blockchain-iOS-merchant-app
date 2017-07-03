//
//  BCMQRCodeScannerViewController.h
//  Merchant
//
//  Created by User on 11/18/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMBaseViewController.h"

extern NSString *const kBCMQrCodeScannerNavigationId;
extern NSString *const kBCMQrCodeScannerViewControllerId;

@class BCMQRCodeScannerViewController;

@protocol BCMQRCodeScannerViewControllerDelegate <NSObject>

- (void)bcmscannerViewController:(BCMQRCodeScannerViewController *)vc didScanString:(NSString *)scanString;
- (void)bcmscannerViewControllerCancel:(BCMQRCodeScannerViewController *)vc;

@end

@interface BCMQRCodeScannerViewController : BCMBaseViewController

@property (weak, nonatomic) id<BCMQRCodeScannerViewControllerDelegate> delegate;

@end
