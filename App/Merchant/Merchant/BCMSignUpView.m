//
//  BCMSignUpView.m
//  Merchant
//
//  Created by User on 11/9/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSignUpView.h"

#import "BCMQRCodeScannerViewController.h"

#import "BCMTextField.h"

#import "BCMMerchantManager.h"

#import "Merchant.h"

#import "ActionSheetStringPicker.h"

#import "BTCAddress.h"
#import "NSData+BTCData.h"
#import "NS+BTCBase58.h"

#import "UIColor+Utilities.h"
#import "Foundation-Utility.h"

#import <CoreBitcoin/CoreBitcoin.h>

@interface BCMSignUpView ()

@property (weak, nonatomic) IBOutlet BCMTextField *nameTextField;
@property (weak, nonatomic) IBOutlet BCMTextField *currencyTextField;
@property (weak, nonatomic) IBOutlet BCMTextField *walletTextField;
@property (weak, nonatomic) IBOutlet BCMTextField *signupTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *qrCodeScanButton;
@property (weak, nonatomic) IBOutlet UIImageView *addressValidateImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *greenCheckContrainst;

@property (strong, nonatomic) UIView *inputAccessoryView;
@property (copy, nonatomic) NSString *tempCurrency;


@end

@implementation BCMSignUpView

- (void)awakeFromNib
{
    [super awakeFromNib];

    CALayer *layer = self.layer;
    layer.shadowOpacity = .5;
    layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    layer.shadowOffset = CGSizeMake(0,0);
    layer.shadowRadius = 8;
    
    self.nameTextField.placeholder = NSLocalizedString(@"signup.business.name", nil);
    self.walletTextField.placeholder = NSLocalizedString(@"signup.wallet.name", nil);
    self.currencyTextField.placeholder = NSLocalizedString(@"signup.currency.name", nil);
    self.signupTextField.placeholder = NSLocalizedString(@"signup.pin.set", nil);
    [self setNeedsLayout];
    [self layoutIfNeeded];

    // Default to USD
    self.tempCurrency = @"USD";
    self.currencyTextField.text = self.tempCurrency;
    
    [self.cancelButton setTitle:NSLocalizedString(@"action.cancel", nil) forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLocalizedString(@"action.save", nil) forState:UIControlStateNormal];
    
    [self addObservers];
    
    self.addressValidateImageView.hidden = YES;
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.walletTextField.textEditingInset = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame), 0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame));
    self.walletTextField.textInset = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame), 0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame));
}

- (void)dealloc
{
    [self removeObservers];
}

@synthesize scannedWalletAddress = _scannedWalletAddress;

- (void)setScannedWalletAddress:(NSString *)scannedWalletAddress
{
    scannedWalletAddress = [scannedWalletAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _scannedWalletAddress = [scannedWalletAddress copy];
    
    self.walletTextField.text = _scannedWalletAddress;
    
    [self updateAddressStatusForAddress:scannedWalletAddress];
}

@synthesize pinRequired = _pinRequired;

- (void)setPinRequired:(BOOL)pinRequired
{
    _pinRequired = pinRequired;
    
    if (_pinRequired) {
        self.signupTextField.placeholder = NSLocalizedString(@"signup.pin.reset", nil);
    } else {
        self.signupTextField.placeholder = NSLocalizedString(@"signup.pin.set", nil);
    }
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(signUpViewDidCancel:)]) {
        [self.delegate signUpViewDidCancel:self];
    }
}

- (IBAction)saveAction:(id)sender
{
    BOOL validAddress = NO;
    if ([self.walletTextField.text length] > 0) {
        if ([BTCAddress addressWithBase58String:self.walletTextField.text]) {
            validAddress = YES;
        }
    }
    
    if ([self.nameTextField.text length] == 0 || [self.walletTextField.text length] == 0 || !validAddress) {
        NSString *alertTitle = NSLocalizedString(@"signup.alert.title", nil);
        NSString *alertMessage = NSLocalizedString(@"signup.warning", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
        [alert show];
    } else {
        Merchant *merchant = [Merchant MR_createEntity];
        merchant.name = self.nameTextField.text;
        merchant.walletAddress = self.walletTextField.text;
        merchant.currency = self.tempCurrency;
        
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(signUpViewDidSave:)]) {
                [self.delegate signUpViewDidSave:self];
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL canEdit = YES;
    
    if (textField == self.currencyTextField) {
        
        // Hide the keyboard if necessary
        [self endEditing:YES];
        
        canEdit = NO;
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *currencyPath = [mainBundle pathForResource:@"SupportedCurrencies" ofType:@"plist"];
        NSArray *currencies = [NSArray arrayWithContentsOfFile:currencyPath];
        
        NSString *currentCurrency = self.tempCurrency;
        
        NSUInteger selectedCurrencyIndex = 0;
        if ([self.tempCurrency length] > 0) {
            selectedCurrencyIndex = [currencies indexOfObject:currentCurrency];
        }
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"currency.picker.title", nil) rows:currencies initialSelection:selectedCurrencyIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.tempCurrency = [currencies objectAtIndex:selectedIndex];
            self.currencyTextField.text = self.tempCurrency;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self];
        [picker showActionSheetPicker];
    } else if (self.signupTextField == textField) {
        canEdit = NO;
        if ([self.delegate respondsToSelector:@selector(signUpViewSetPin:)]) {
            [self.delegate signUpViewSetPin:self];
        }
    } else {
        textField.inputAccessoryView = [self inputAccessoryView];
    }
    
    if (textField == self.walletTextField) {
        self.walletTextField.textEditingInset = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame), 0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame));
        self.walletTextField.textInset = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame), 0.0f, CGRectGetMaxX(self.walletTextField.frame) - CGRectGetMinX(self.qrCodeScanButton.frame));
    }
    
    return canEdit;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.walletTextField) {
        self.greenCheckContrainst.constant = -1.0f * CGRectGetWidth(self.addressValidateImageView.frame);
        self.addressValidateImageView.hidden = NO;
        NSString *walletAddress = [self.walletTextField.text stringByReplacingCharactersInRange:range withString:string];
        [self updateAddressStatusForAddress:walletAddress];
    }
    
    return YES;
}

- (void)updateAddressStatusForAddress:(NSString *)address
{
    self.greenCheckContrainst.constant = -1.0f * CGRectGetWidth(self.addressValidateImageView.frame);
    self.addressValidateImageView.hidden = NO;
    if ([address length] > 0) {
        if ([BTCAddress addressWithBase58String:address]) {
            self.addressValidateImageView.image = [UIImage imageNamed:@"green_check"];
        } else {
            self.addressValidateImageView.image = [UIImage imageNamed:@"red_x"];
        }
    } else {
        self.greenCheckContrainst.constant = 0.0f;
        self.addressValidateImageView.image = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        UIView *parentView = [self superview];
        CGRect accessFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(parentView.frame), 54.0f);
        self.inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        self.inputAccessoryView.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
        UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        compButton.frame = CGRectMake(CGRectGetWidth(parentView.frame) - 80.0f, 10.0, 80.0f, 40.0f);
        [compButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [compButton setTitle: @"Done" forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compButton addTarget:self action:@selector(accessoryDoneAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.inputAccessoryView addSubview:compButton];
    }
    return _inputAccessoryView;
}

- (IBAction)qrCodeScanAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(signUpViewRequestScanQRCode:)]) {
        [self.delegate signUpViewRequestScanQRCode:self];
    }
}

- (void)accessoryDoneAction:(id)sender
{
    [self endEditing:YES];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.walletTextField isFirstResponder]) {
        NSDictionary *dict = notification.userInfo;
        NSValue *endRectValue = [dict safeObjectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect endKeyboardFrame = [endRectValue CGRectValue];
        CGRect convertedEndKeyboardFrame = [[self superview] convertRect:endKeyboardFrame fromView:nil];
        CGRect convertedWalletFrame = [[self superview] convertRect:self.walletTextField.frame fromView:self.scrollView];
        CGFloat lowestPoint = CGRectGetMaxY(convertedWalletFrame);
        
        // If the ending keyboard frame overlaps our
        if (lowestPoint > CGRectGetMinY(convertedEndKeyboardFrame)) {
            self.scrollView.scrollEnabled = YES;
            self.scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, lowestPoint - CGRectGetMinY(convertedEndKeyboardFrame), 0.0f);
            [self.scrollView setContentOffset:CGPointMake(0.0f, lowestPoint - CGRectGetMinY(convertedEndKeyboardFrame)) animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = NO;
        
        NSDictionary *dict = notification.userInfo;
        NSTimeInterval duration = [[dict safeObjectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[dict safeObjectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        self.scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
}

@end
