#import "_Merchant.h"

extern NSString *const kBCMBusinessName;
extern NSString *const kBCMBusinessCategory;
extern NSString *const kBCMBusinessStreetAddress;
extern NSString *const kBCMBusinessCityAddress;
extern NSString *const kBCMBusinessZipcodeAddress;

extern NSString *const kBCMBusinessLatitude;
extern NSString *const kBCMBusinessLongitude;
extern NSString *const kBCMBusinessTelephone;
extern NSString *const kBCMBusinessWebURL;
extern NSString *const kBCMBusinessDescription;

extern NSString *const kBCMBusinessCurrency;
extern NSString *const kBCMBusinessDirectoryListing;
extern NSString *const kBCMBusinessWalletAddress;


@interface Merchant : _Merchant {}

- (NSDictionary *)merchantAsSuggestionDict;

@end
