//
//  BCAddItem.m
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMAddItem.h"

#import "BCMTextField.h"

#import "Item.h"
#import "Merchant.h"
#import "BCMMerchantManager.h"

#import "UIColor+Utilities.h"
#import "Foundation-Utility.h"

@interface BCMAddItem ()

@property (weak, nonatomic) IBOutlet BCMTextField *itemNameTextField;
@property (weak, nonatomic) IBOutlet BCMTextField *itemPriceTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIView *inputAccessoryView;

@end

@implementation BCMAddItem

- (void)awakeFromNib
{
    CALayer *layer = self.layer;
    layer.shadowOpacity = .5;
    layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    layer.shadowOffset = CGSizeMake(0,0);
    layer.shadowRadius = 8;
    
    [self addObservers];
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

- (void)dealloc
{
    [self removeObservers];
}

@synthesize item = _item;

- (void)setItem:(Item *)item
{
    _item = item;
    
    NSString *itemName = _item.name;
    if ([itemName length] > 0) {
        self.itemNameTextField.text = _item.name;
    }
    
    if ([_item.price floatValue] > 0) {
        NSString *price = @"";
        if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
            price = [NSString stringWithFormat:@"%.4f", [_item.price floatValue]];
        } else {
            price = [NSString stringWithFormat:@"%.2f", [_item.price floatValue]];
        }
        self.itemPriceTextField.text = price;
    }
}

#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    NSString *itemName = [self.itemNameTextField text];
    NSString *itemPrice = [self.itemPriceTextField text];
    if ([itemName length] == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addItem.error.missing.name", nil) message:NSLocalizedString(@"addItem.error.missing.name.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil] show];
    } else if ([itemPrice length] == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addItem.error.missing.price", nil) message:NSLocalizedString(@"addItem.error.missing.price.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil] show];
    } else if ([itemPrice floatValue] == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addItem.error.zero.price", nil) message:NSLocalizedString(@"addItem.error.zero.price.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil] show];
    } else {
        
        if (self.item) {
            NSString *itemName = [self.itemNameTextField text];
            NSString *itemPrice = [self.itemPriceTextField text];
            self.item.name = itemName;
            self.item.priceValue = [itemPrice floatValue];
            if ([self.delegate respondsToSelector:@selector(addItemView:didSaveItem:)]) {
                [self.delegate addItemView:self didSaveItem:self.item];
            }
        } else {
            Item *item = [Item MR_createEntity];
            item.name = itemName;
            CGFloat floatPrice = [itemPrice floatValue];
            item.price = [NSNumber numberWithFloat:floatPrice];
            if ([self.delegate respondsToSelector:@selector(addItemView:didSaveItem:)]) {
                [self.delegate addItemView:self didSaveItem:item];
            }
        }
    }
}

- (IBAction)cancelAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addItemViewDidCancel:)]) {
        [self.delegate addItemViewDidCancel:self];
    }
}

- (void)accessoryDoneAction:(id)sender
{
    [self endEditing:YES];
}

#pragma mark - UITextFieldDelegate

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

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.itemPriceTextField isFirstResponder]) {
        NSDictionary *dict = notification.userInfo;
        NSValue *endRectValue = [dict safeObjectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect endKeyboardFrame = [endRectValue CGRectValue];
        CGRect convertedEndKeyboardFrame = [[self superview] convertRect:endKeyboardFrame fromView:nil];
        CGRect convertedWalletFrame = [[self superview] convertRect:self.itemPriceTextField.frame fromView:self.scrollView];
        CGFloat lowestPoint = CGRectGetMaxY(convertedWalletFrame);
        
        // If the ending keyboard frame overlaps our textfield
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
