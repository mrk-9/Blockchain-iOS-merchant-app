#import "_Transaction.h"

@interface Transaction : _Transaction {}

- (NSDecimalNumber *)transactionTotal;
- (NSDecimalNumber *)decimalBitcoinAmountValue;
- (void)setDecimalBitcoinAmountValue:(NSString *)value;
@end
