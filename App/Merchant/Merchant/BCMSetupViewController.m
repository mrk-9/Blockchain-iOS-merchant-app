//
//  BCMSetupViewController.m
//  Merchant
//
//  Created by User on 11/9/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSetupViewController.h"

#import "BCMQRCodeScannerViewController.h"
#import "BCPinEntryViewController.h"

#import "BCMMerchantManager.h"

#import "BCMSignUpView.h"

#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

#import "DebugTableViewController.h"

NSString *const kNavStoryboardSetupVCId = @"navSetupStoryBoardId";
NSString *const kStoryboardSetupVCId = @"setupStoryBoardId";

@interface BCMSetupViewController () <BCMSignUpViewDelegate, BCMQRCodeScannerViewControllerDelegate, BCPinEntryViewControllerDelegate>

@property (strong, nonatomic) UIView *whiteOverlayView;
@property (strong, nonatomic) BCMSignUpView *signUpView;
@property (weak, nonatomic) IBOutlet UIButton *goButton;

@property (copy, nonatomic) NSString *temporaryPin;

@property (strong, nonatomic) IBOutlet UIView *debugView;
@end

@implementation BCMSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 2.0;
    [self.debugView addGestureRecognizer:longPressGesture];
    
    self.view.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
    
    [self.goButton setTitleColor:[UIColor colorWithHexValue:BCM_BLUE] forState:UIControlStateNormal];
    
    [self.goButton setBackgroundColor:[UIColor whiteColor]];
    [self.goButton.layer setCornerRadius:CGRectGetHeight(self.goButton.frame) / 2.5f];

    // Adding initial overlay view so we can animate the alpha when needed
    if (!self.whiteOverlayView) {
        self.whiteOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.whiteOverlayView.backgroundColor = [UIColor whiteColor];
        self.whiteOverlayView.alpha = 0.0f;
        [self.view addSubview:self.whiteOverlayView];
    }
}

- (void)showSignUpView
{
    if (self.whiteOverlayView.alpha == 0.0f) {
        [self.view bringSubviewToFront:self.whiteOverlayView];
        [UIView animateWithDuration:0.25f animations:^{
            self.whiteOverlayView.alpha = 1.0f;
        }];
    }
    
    if (!self.signUpView) {
        self.signUpView = [BCMSignUpView loadInstanceFromNib];
        self.signUpView.translatesAutoresizingMaskIntoConstraints = NO;
        self.signUpView.delegate = self;
    }
    [self.view addSubview:self.signUpView];

    NSLayoutConstraint *leadingContrainst = [NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.0f];
    NSLayoutConstraint *trailingContrainst = [NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-20.0f];
    NSLayoutConstraint *topContrainst = [NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f];
    NSLayoutConstraint *bottomContrainst = [NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-20.0f];
    NSLayoutConstraint *horizontalCenterConstraint = [NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *verticalCenterConstraint = [NSLayoutConstraint constraintWithItem:self.signUpView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    [self.view addConstraint:leadingContrainst];
    [self.view addConstraint:trailingContrainst];
    [self.view addConstraint:topContrainst];
    [self.view addConstraint:bottomContrainst];
    [self.view addConstraint:horizontalCenterConstraint];
    [self.view addConstraint:verticalCenterConstraint];
}

- (void)viewDidLayoutSubviews
{
    [self.signUpView setNeedsLayout];
}

- (void)hideSignUpView:(BCMSignUpView *)signUpView
{
    [signUpView removeFromSuperview];
    [UIView animateWithDuration:0.25f animations:^{
        self.whiteOverlayView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.whiteOverlayView];
        self.signUpView = nil;
    }];
}

#pragma mark - Actions

- (IBAction)signUpAction:(id)sender
{
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self showDebugMenu];
    }
}

- (void)showDebugMenu
{
    DebugTableViewController *debugViewController = [[DebugTableViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:debugViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - BCMSignUpViewDelegate

- (void)signUpViewDidCancel:(BCMSignUpView *)signUpView
{
    [self hideSignUpView:signUpView];
}

- (void)signUpViewDidSave:(BCMSignUpView *)signUpView
{
    [[BCMMerchantManager sharedInstance] pinEntryViewController:nil successfulEntry:YES pin:self.temporaryPin];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewSetPin:(BCMSignUpView *)signUpView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
    UINavigationController *pinEntryViewNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kPinEntryStoryboardId];
    BCPinEntryViewController *entryViewController = (BCPinEntryViewController *)pinEntryViewNavController.topViewController;
    
    if ([self.temporaryPin length] > 0) {
        entryViewController.userMode = PinEntryUserModeReset;
    } else {
        entryViewController.userMode = PinEntryUserModeCreate;
    }
    entryViewController.delegate = self;
    [self presentViewController:pinEntryViewNavController animated:YES completion:nil];
}

- (void)signUpViewRequestScanQRCode:(BCMSignUpView *)signUpView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
    UINavigationController *scannerNavigationController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMQrCodeScannerNavigationId];
    BCMQRCodeScannerViewController *scannerViewController = (BCMQRCodeScannerViewController *)scannerNavigationController.topViewController;
    scannerViewController.delegate = self;
    [self presentViewController:scannerNavigationController animated:YES completion:nil];
}

#pragma mark - BCMQRCodeScannerViewControllerDelegate

- (void)bcmscannerViewController:(BCMQRCodeScannerViewController *)vc didScanString:(NSString *)scanString
{
    scanString = [scanString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"bitcoin://" withString:@""];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
    self.signUpView.scannedWalletAddress = scanString;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)bcmscannerViewControllerCancel:(BCMQRCodeScannerViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BCPinEntryViewControllerDelegate

- (BOOL)pinEntryViewController:(BCPinEntryViewController *)pinVC validatePin:(NSString *)pin
{
    return [self.temporaryPin isEqualToString:pin];
}

- (void)pinEntryViewController:(BCPinEntryViewController *)pinVC successfulEntry:(BOOL)success pin:(NSString *)pin
{
    self.temporaryPin = pin;
    self.signUpView.pinRequired = [self.temporaryPin length] > 0;
}

@end
