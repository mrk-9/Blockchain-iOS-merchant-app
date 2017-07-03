#import "PurchasedItem.h"


@interface PurchasedItem ()

// Private interface goes here.

@end


@implementation PurchasedItem

- (NSDecimalNumber *)decimalPrice
{
    return [NSDecimalNumber decimalNumberWithDecimal:[self.price decimalValue]];
}
// Custom logic goes here.

@end
