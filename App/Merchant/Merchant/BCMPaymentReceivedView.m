//
//  BCMPaymentReceivedView.m
//  Merchant
//
//  Created by User on 11/4/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMPaymentReceivedView.h"

#import "BCMTextField.h"

#import "UIColor+Utilities.h"
#import "Foundation-Utility.h"

@interface BCMPaymentReceivedView ()

@property (weak, nonatomic) IBOutlet BCMTextField *emailTextField;

@property (strong, nonatomic) UIView *inputAccessoryView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;

@end

@implementation BCMPaymentReceivedView

- (IBAction)emailAction:(id)sender
{
    NSString *emailText = self.emailTextField.text;
    
    if (![self validateEmail:emailText]) {
        NSString *ok = NSLocalizedString(@"alert.ok", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"merchant.email.invalid", nil) message:NSLocalizedString(@"merchant.email.invalid.detail", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:ok, nil];
        [alert show];
    } else {
        if ([self.delegate respondsToSelector:@selector(dismissPaymentReceivedView:withEmail:)]) {
            [self.delegate dismissPaymentReceivedView:self withEmail:emailText];
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.emailButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.doneButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
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

- (void)clearRecipient
{
    self.emailTextField.text = @"";
}

- (IBAction)doneAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dismissPaymentReceivedView:withEmail:)]) {
        [self.delegate dismissPaymentReceivedView:self withEmail:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self inputAccessoryView];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(paymentReceivedView:emailTextFieldDidBecomeFirstResponder:)]) {
        [self.delegate paymentReceivedView:self emailTextFieldDidBecomeFirstResponder:self.emailTextField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(paymentReceivedView:emailTextFieldDidResignFirstResponder:)]) {
        [self.delegate paymentReceivedView:self emailTextFieldDidResignFirstResponder:self.emailTextField];
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
        [compButton setTitle:NSLocalizedString(@"general.done", nil) forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compButton addTarget:self action:@selector(accessoryDoneAction:)
             forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(0, 10.0, 80.0f, 40.0f);
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [cancelButton setTitle:NSLocalizedString(@"action.cancel", nil) forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(accessoryCancelAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [self.inputAccessoryView addSubview:cancelButton];
        [self.inputAccessoryView addSubview:compButton];
    }
    return _inputAccessoryView;
}

- (void)accessoryCancelAction:(id)sender
{
    [self endEditing:YES];
}

- (void)accessoryDoneAction:(id)sender
{
    [self endEditing:YES];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.emailTextField isFirstResponder]) {
        NSDictionary *dict = notification.userInfo;
        NSValue *endRectValue = [dict safeObjectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect endKeyboardFrame = [endRectValue CGRectValue];
        CGRect convertedEndKeyboardFrame = [[self superview] convertRect:endKeyboardFrame fromView:nil];
        CGRect convertedWalletFrame = [[self superview] convertRect:self.emailTextField.frame fromView:self.scrollView];
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

- (BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


@end
