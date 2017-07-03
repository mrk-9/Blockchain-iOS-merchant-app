//
//  BCMCustomAmountView.m
//  Merchant
//
//  Created by User on 10/28/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMCustomAmountView.h"

#import "BCMTextField.h"
#import "BCMNetworking.h"
#import "BCMMerchantManager.h"
#import "Merchant.h"
#import "Foundation-Utility.h"

#import "UIColor+Utilities.h"

@interface BCMCustomAmountView () <UITextFieldDelegate>

@property (strong, nonatomic) UIView *inputAccessoryView;
@property (nonatomic) UIButton *compButton;
@end

@implementation BCMCustomAmountView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.currencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    self.currencyLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.098/255.0 alpha:0.22];
    self.customAmountTextField.rightView = self.currencyLabel;
    self.customAmountTextField.rightViewMode = UITextFieldViewModeAlways;
    self.customAmountTextField.textEditingInset = UIEdgeInsetsMake(0, 50, 0, 50);
    self.customAmountTextField.minimumFontSize = 20;
}

- (void)clear
{
    self.customAmountTextField.text = @"";
    if ([self.delegate respondsToSelector:@selector(updateBitcoinAmountLabel:)]) {
        [self.delegate updateBitcoinAmountLabel:self.customAmountTextField.text];
    }
}

- (void)enableCharge
{
    self.compButton.enabled = YES;
}

- (void)disableCharge
{
    self.compButton.enabled = NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(updateBitcoinAmountLabel:)]) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
        NSString *convertedText = [newString stringByReplacingOccurrencesOfString:decimalSeparator withString:@"."];
        [self.delegate updateBitcoinAmountLabel:convertedText];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self inputAccessoryView];
    
    return YES;
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
        compButton.frame = CGRectMake(CGRectGetWidth(self.window.frame) - 85.0f, CGRectGetHeight(self.inputAccessoryView.frame)/2-20, 85.0f, 40.0f);
        [compButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [compButton setTitle: NSLocalizedString(@"action.charge", nil) forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [compButton addTarget:self action:@selector(accessoryDoneAction:)
             forControlEvents:UIControlEventTouchUpInside];
        compButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.compButton = compButton;

        [self.inputAccessoryView addSubview:compButton];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.inputAccessoryView.frame)/2-20, 80.0f, 40.0f);
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [cancelButton setTitle: NSLocalizedString(@"action.cancel", nil) forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(accessoryClearAction:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.inputAccessoryView addSubview:cancelButton];
    }
    return _inputAccessoryView;
}

- (void)accessoryDoneAction:(id)sender
{
    NSString *amountText = [self.customAmountTextField.text stringByReplacingOccurrencesOfString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator] withString:@"."];
    
    if ([amountText length] == 0) {
        amountText = @"0.00";
    }
    
    NSString *currency = [BCMMerchantManager sharedInstance].activeMerchant.currency;
    [[BCMNetworking sharedInstance] convertToBitcoinFromAmount:[NSDecimalNumber decimalNumberWithString:amountText] fromCurrency:[currency uppercaseString] success:^(NSURLRequest *request, NSDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Need to set bitcoin price
            NSString *bitcoinValue = [dict safeObjectForKey:@"btcValue"];
            if ([self.delegate respondsToSelector:@selector(customAmountView:addCustomAmount:bitcoinAmount:)]) {
                [self.delegate customAmountView:self addCustomAmount:[NSDecimalNumber decimalNumberWithString:amountText] bitcoinAmount:bitcoinValue];
                
                if ([self.delegate respondsToSelector:@selector(chargeAction:)]) {
                    [self.delegate chargeAction:nil];
                }
            }
#ifdef MOCK_BTC_TRANSACTION
            [self performSelector:@selector(transactionCompleted) withObject:nil afterDelay:1.0f];
#endif
        });
    } error:^(NSURLRequest *request, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
#ifdef MOCK_BTC_TRANSACTION
            [self performSelector:@selector(transactionCompleted) withObject:nil afterDelay:1.0f];
#endif
            // Display alert to prevent the user from continuing
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"network.problem.title", nil) message:NSLocalizedString(@"network.problem.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
            [alertView show];
        });
    }];
    
    [self endEditing:YES];
}

- (void)accessoryClearAction:(id)sender
{
    [self clear];
}

@end
