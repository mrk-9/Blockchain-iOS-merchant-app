//
//  BCMCustomAmountView.h
//  Merchant
//
//  Created by User on 10/28/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCMTextField;

@class BCMCustomAmountView;

@protocol BCMCustomAmountViewDelegate <NSObject>

- (void)customAmountView:(BCMCustomAmountView *)amountView addCustomAmount:(NSDecimalNumber *)amount bitcoinAmount:(NSString *)bitcoinAmount;
- (void)chargeAction:(id)sender;
- (void)updateBitcoinAmountLabel:(NSString *)convertedText;

@end

@interface BCMCustomAmountView : UIView

@property (weak, nonatomic) id <BCMCustomAmountViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet BCMTextField *customAmountTextField;
@property (weak, nonatomic) IBOutlet UILabel *btcAmountLabel;
@property (nonatomic) UILabel *currencyLabel;

- (void)clear;
- (void)disableCharge;
- (void)enableCharge;

@end
