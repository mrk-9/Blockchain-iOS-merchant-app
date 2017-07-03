//
//  BCMTransactionTableViewCell.m
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMTransactionTableViewCell.h"

#import "Transaction.h"
#import "PurchasedItem.h"

#import "NSDate+Utilities.h"

@interface BCMTransactionTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *amountLbl;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@end

@implementation BCMTransactionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

@synthesize transaction = _transaction;

- (void)setTransaction:(Transaction *)transaction
{
    _transaction = transaction;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMinimumIntegerDigits:1];
    [numberFormatter setMinimumFractionDigits:8];
    self.amountLbl.text = [NSString stringWithFormat:@"%1@ BTC", [numberFormatter stringFromNumber:[transaction decimalBitcoinAmountValue]]];
    PurchasedItem *item = transaction.purchasedItems.allObjects.firstObject;
    if ([item.name isEqualToString:NSLocalizedString(@"qr.insufficient.payment.title", @"")]) {
        self.checkImageView.hidden = YES;
    } else {
        self.checkImageView.hidden = NO;
    }
    
    NSDate *transactionDate = _transaction.creation_date;
    
    NSTimeInterval secondsBeforeNow = [[NSDate date] timeIntervalSinceDate:transactionDate];
    
    NSString *timeUnit = nil;
    NSString *timeValue = nil;

    if (secondsBeforeNow < 60) {
        timeUnit = NSLocalizedString(@"transaction.detail.seconds", nil);
        timeValue = [NSString stringWithFormat:NSLocalizedString(@"transaction.detail.time.ago", nil), (float)secondsBeforeNow, timeUnit];
    } else if (secondsBeforeNow >= 60 && secondsBeforeNow < 3600) {
        timeUnit = NSLocalizedString(@"transaction.detail.minutes", nil);
        timeValue = [NSString stringWithFormat:NSLocalizedString(@"transaction.detail.time.ago", nil), ceilf(secondsBeforeNow / 60), timeUnit];
    } else {
        timeUnit = @"";
        timeValue = [transactionDate shortDateString];
    }
    
    self.timeLbl.text = timeValue;
}

@end
