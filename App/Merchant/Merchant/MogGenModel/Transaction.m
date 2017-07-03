#import "Transaction.h"
#import "PurchasedItem.h"

@interface Transaction ()

// Private interface goes here.

@end


@implementation Transaction

- (NSDecimalNumber *)transactionTotal
{
    NSDecimalNumber *purchaseSum = [NSDecimalNumber zero];
    
    for (PurchasedItem *item in [self.purchasedItems allObjects]) {
        purchaseSum = [purchaseSum decimalNumberByAdding:item.decimalPrice];
    }
    
    return purchaseSum;
}

- (NSDecimalNumber *)decimalBitcoinAmountValue
{
    return [NSDecimalNumber decimalNumberWithDecimal:[self.bitcoinAmount decimalValue]];
}

- (void)setDecimalBitcoinAmountValue:(NSString *)value
{
    self.bitcoinAmount = [NSDecimalNumber decimalNumberWithString:value];
}

@end
