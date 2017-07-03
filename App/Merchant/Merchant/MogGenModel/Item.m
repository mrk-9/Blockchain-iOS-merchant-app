#import "Item.h"

NSString *const kItemNameKey = @"name";
NSString *const kItemPriceKey = @"price";
NSString *const kItemBtcPriceKey = @"btcPrice";

@interface Item ()

// Private interface goes here.

@end

@implementation Item

@dynamic name;
@dynamic price;
@dynamic creation_date;

- (NSDictionary *)itemAsDict
{
    NSString *itemName = @"";
    NSNumber *itemPrice = [NSNumber numberWithFloat:0.0f];
    
    if ([self.name length] > 0) {
        itemName = self.name;
    }
    
    if (self.price) {
        itemPrice = self.price;
    }
    
    return @{ kItemNameKey : itemName, kItemPriceKey : itemPrice };
}

@end
