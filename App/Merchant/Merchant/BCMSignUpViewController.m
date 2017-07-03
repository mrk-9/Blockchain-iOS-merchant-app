//
//  BCMSignUpViewController.m
//  Merchant
//
//  Created by User on 4/6/15.
//  Copyright (c) 2015 com. All rights reserved.
//

#import "BCMSignUpViewController.h"
#import "BCMQRCodeScannerViewController.h"

#import "BCMTextField.h"

#import "BCMMerchantManager.h"

#import "Merchant.h"
#import "BTCAddress.h"

#import "ActionSheetStringPicker.h"

#import "BTCAddress.h"
#import "NSData+BTCData.h"
#import "NS+BTCBase58.h"

#import "AppDelegate.h"
#import "BCMDrawerViewController.h"

#import "UIColor+Utilities.h"
#import "Foundation-Utility.h"

#import <CoreBitcoin/CoreBitcoin.h>

@interface BCMSignUpViewController () <BCMQRCodeScannerViewControllerDelegate, BCPinEntryViewControllerDelegate>

@property (weak, nonatomic) IBOutlet BCMTextField *businessNameTextfield;
@property (weak, nonatomic) IBOutlet BCMTextField *currencyTextfield;
@property (weak, nonatomic) IBOutlet BCMTextField *walletTextfield;
@property (weak, nonatomic) IBOutlet BCMTextField *signupTextfield
;
@property (weak, nonatomic) IBOutlet UIButton *qrCodeScanButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *letsButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *greenCheckConstraint;

@property (copy, nonatomic) NSString *tempCurrency;
@property (copy, nonatomic) NSString *temporaryPin;

@property (strong, nonatomic) UIView *inputAccessoryView;

@end

@implementation BCMSignUpViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.businessNameTextfield.textInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.currencyTextfield.textInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.walletTextfield.textInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.signupTextfield.textInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.businessNameTextfield.textEditingInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.currencyTextfield.textEditingInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.walletTextfield.textEditingInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.signupTextfield.textEditingInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    
    self.businessNameTextfield.placeholder = NSLocalizedString(@"signup.business.name", nil);
    self.walletTextfield.placeholder = NSLocalizedString(@"signup.wallet.name", nil);
    self.currencyTextfield.placeholder = NSLocalizedString(@"signup.currency.name", nil);
    self.signupTextfield.placeholder = NSLocalizedString(@"signup.pin.set", nil);
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    // Default to USD
    self.tempCurrency = @"USD";
    self.currencyTextfield.text = self.tempCurrency;
    
    [self.cancelButton setTitle:NSLocalizedString(@"action.cancel", nil) forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLocalizedString(@"action.save", nil) forState:UIControlStateNormal];
    
    [self addObservers];
    
    self.navigationItem.titleView = nil;
    
    self.checkImageView.hidden = YES;
    
    self.greenCheckConstraint.constant = -1.0f * CGRectGetWidth(self.checkImageView.frame);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.temporaryPin length]) {
        self.signupTextfield.placeholder = NSLocalizedString(@"signup.pin.reset", nil);
    } else {
        self.signupTextfield.placeholder = NSLocalizedString(@"signup.pin.set", nil);
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender
{
    BOOL validAddress = NO;
    if ([self.walletTextfield.text length] > 0) {
        if ([BTCAddress addressWithBase58String:self.walletTextfield.text]) {
            validAddress = YES;
        }
    }
    
    if ([self.businessNameTextfield.text length] == 0 || [self.walletTextfield.text length] == 0 || !validAddress) {
        NSString *alertTitle = NSLocalizedString(@"signup.alert.title", nil);
        NSString *alertMessage = NSLocalizedString(@"signup.warning", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
        [alert show];
    } else {
        Merchant *merchant = [Merchant MR_createEntity];
        merchant.name = self.businessNameTextfield.text;
        merchant.walletAddress = self.walletTextfield.text;
        merchant.currency = self.tempCurrency;
        
        [[BCMMerchantManager sharedInstance] pinEntryViewController:nil successfulEntry:YES pin:self.temporaryPin];
        [self dismissViewControllerAnimated:NO completion:^{
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            BCMDrawerViewController *drawer = delegate.drawerController;
            [drawer dismissViewControllerAnimated:NO completion:nil];
        }];
        
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL canEdit = YES;
    
    if (textField == self.currencyTextfield) {
        
        // Hide the keyboard if necessary
        [self.view endEditing:YES];
        
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
            self.currencyTextfield.text = self.tempCurrency;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self.view];
        [picker showActionSheetPicker];
    } else if (self.signupTextfield == textField) {
        canEdit = NO;
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
    } else {
        textField.inputAccessoryView = [self inputAccessoryView];
    }
    
    return canEdit;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.walletTextfield) {
        self.greenCheckConstraint.constant = -1.0f * CGRectGetWidth(self.checkImageView.frame);
        self.checkImageView.hidden = NO;
        NSString *walletAddress = [self.walletTextfield.text stringByReplacingCharactersInRange:range withString:string];
        [self updateAddressStatusForAddress:walletAddress];
    }
    
    return YES;
}

- (void)updateAddressStatusForAddress:(NSString *)address
{
    self.greenCheckConstraint.constant = -1.0f * CGRectGetWidth(self.checkImageView.frame);
    self.checkImageView.hidden = NO;
    if ([address length] > 0) {
        self.greenCheckConstraint.constant = 2.0f;
        if ([BTCAddress addressWithBase58String:address]) {
            self.checkImageView.image = [UIImage imageNamed:@"valid_address"];
        } else {
            self.checkImageView.image = [UIImage imageNamed:@"not_valid_address"];
        }
    } else {
        self.greenCheckConstraint.constant = 0.0f;
        self.checkImageView.image = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        UIView *parentView = self.view;
        CGRect accessFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(parentView.frame), 54.0f);
        self.inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        self.inputAccessoryView.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
        UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        compButton.frame = CGRectMake(CGRectGetWidth(parentView.frame) - 80.0f, 10.0, 80.0f, 40.0f);
        [compButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [compButton setTitle:NSLocalizedString(@"general.done", nil) forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compButton addTarget:self action:@selector(accessoryDoneAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.inputAccessoryView addSubview:compButton];
    }
    return _inputAccessoryView;
}

- (IBAction)qrCodeScanAction:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
    UINavigationController *scannerNavigationController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMQrCodeScannerNavigationId];
    BCMQRCodeScannerViewController *scannerViewController = (BCMQRCodeScannerViewController *)scannerNavigationController.topViewController;
    scannerViewController.delegate = self;
    [self presentViewController:scannerNavigationController animated:YES completion:nil];

}

- (void)accessoryDoneAction:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.walletTextfield isFirstResponder]) {
        NSDictionary *dict = notification.userInfo;
        NSValue *endRectValue = [dict safeObjectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect endKeyboardFrame = [endRectValue CGRectValue];
        CGRect convertedEndKeyboardFrame = [[self.view superview] convertRect:endKeyboardFrame fromView:nil];
        CGRect convertedWalletFrame = [[self.view superview] convertRect:self.walletTextfield.frame fromView:self.scrollView];
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

#pragma mark - BCPinEntryViewControllerDelegate

- (BOOL)pinEntryViewController:(BCPinEntryViewController *)pinVC validatePin:(NSString *)pin
{
    return [self.temporaryPin isEqualToString:pin];
}

- (void)pinEntryViewController:(BCPinEntryViewController *)pinVC successfulEntry:(BOOL)success pin:(NSString *)pin
{
    self.temporaryPin = pin;
    self.signupTextfield.placeholder = NSLocalizedString(@"signup.pin.reset", nil);
}

#pragma mark - BCMQRCodeScannerViewControllerDelegate

- (void)bcmscannerViewController:(BCMQRCodeScannerViewController *)vc didScanString:(NSString *)scanString
{
    scanString = [scanString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"bitcoin://" withString:@""];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
    self.walletTextfield.text = scanString;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)bcmscannerViewControllerCancel:(BCMQRCodeScannerViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end

