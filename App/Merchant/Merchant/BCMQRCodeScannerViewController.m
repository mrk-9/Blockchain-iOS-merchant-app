//
//  BCMQRCodeScannerViewController.m
//  Merchant
//
//  Created by User on 11/18/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMQRCodeScannerViewController.h"

#import <CoreBitcoin/CoreBitcoin.h>
@import AVFoundation;

NSString *const kBCMQrCodeScannerNavigationId = @"qrCodeScannerNavigationId";
NSString *const kBCMQrCodeScannerViewControllerId = @"qrCodeScannerViewControllerId";

@interface BCMQRCodeScannerViewController ()

@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (strong, nonatomic) UIView *btcScanView;

@end

@implementation BCMQRCodeScannerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self addNavigationType:BCMNavigationTypeCancel position:BCMNavigationPositionLeft selector:@selector(cancelAction:)];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self requestCameraPermissionIfNeeded];
}

- (void)prepareForScanning
{
    if (!self.btcScanView) {
        self.btcScanView = [BTCQRCode scannerViewWithBlock:^(NSString *message) {
            if ([self.delegate respondsToSelector:@selector(bcmscannerViewController:didScanString:)]) {
                [self.delegate bcmscannerViewController:self didScanString:message];
            }
        }];
        self.btcScanView.frame = self.view.bounds;
        [self.view addSubview:self.btcScanView];
    }
}

- (void)requestCameraPermissionIfNeeded
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                // Okay
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareForScanning];
                });
            } else {
                // Denied
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"qr.scanning.permission.title", nil) message:NSLocalizedString(@"qr.scanning.permission.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
                    [alertView show];
                });
            }
        }];
    } else {
        // Prior iOS7
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareForScanning];
        });

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
