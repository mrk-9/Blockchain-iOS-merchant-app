#import "_Item.h"

extern NSString *const kItemNameKey;
extern NSString *const kItemPriceKey;
extern NSString *const kItemBtcPriceKey;

@interface Item : _Item {}

- (NSDictionary *)itemAsDict;

@end
