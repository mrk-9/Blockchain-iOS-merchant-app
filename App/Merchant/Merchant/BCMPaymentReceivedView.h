//
//  BCMPaymentReceivedView.h
//  Merchant
//
//  Created by User on 11/4/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCMPaymentReceivedView;
@class BCMTextField;

@protocol BCMPaymentReceivedViewDelegate <NSObject>

- (void)paymentReceivedView:(BCMPaymentReceivedView *)paymentView emailTextFieldDidBecomeFirstResponder:(BCMTextField *)textField;
- (void)paymentReceivedView:(BCMPaymentReceivedView *)paymentView emailTextFieldDidResignFirstResponder:(BCMTextField *)textField;

- (void)dismissPaymentReceivedView:(BCMPaymentReceivedView *)paymentView withEmail:(NSString *)email;

@end

@interface BCMPaymentReceivedView : UIView

@property (weak, nonatomic) id <BCMPaymentReceivedViewDelegate> delegate;

- (void)clearRecipient;

@end
