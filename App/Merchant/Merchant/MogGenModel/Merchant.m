#import "Merchant.h"

#import "Foundation-Utility.h"

NSString *const kBCMBusinessName = @"BCMBusinessName";
NSString *const kBCMBusinessCategory = @"BCMBusinessCategory";
NSString *const kBCMBusinessStreetAddress = @"BCMBusinessStreetAddress";
NSString *const kBCMBusinessCityAddress = @"BCMBusinessCityAddress";
NSString *const kBCMBusinessZipcodeAddress = @"BCMBusinessZipcodeAddress";
NSString *const kBCMBusinessLatitude = @"BCMBusinessLatitude";
NSString *const kBCMBusinessLongitude = @"BCMBusinessLongitude";
NSString *const kBCMBusinessTelephone = @"BCMBusinessTelephone";
NSString *const kBCMBusinessWebURL = @"BCMBusinessWebURL";
NSString *const kBCMBusinessDescription = @"BCMBusinessDescription";

NSString *const kBCMBusinessCurrency = @"BCMBusinessCurrency";
NSString *const kBCMBusinessDirectoryListing = @"BCMBusinessDirectoryListing";
NSString *const kBCMBusinessWalletAddress = @"BCMBusinessWalletAddress";

@interface Merchant ()

// Private interface goes here.

@end


@implementation Merchant

- (NSDictionary *)merchantAsSuggestionDict
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if ([self.name length] > 0) {
        [dict setObjectOrNil:self.name forKey:@"NAME"];
    }
    
    if (self.businessCategory) {
        [dict setObjectOrNil:[self.businessCategory stringValue] forKey:@"CATEGORY"];
    }
    
    if ([self.streetAddress length] > 0) {
        [dict setObjectOrNil:self.streetAddress forKey:@"STREET_ADDRESS"];
    }
    
    if ([self.city length] > 0) {
        [dict setObjectOrNil:self.city forKey:@"CITY"];
    }
    
    if ([self.zipcode length] > 0) {
        [dict setObjectOrNil:self.zipcode forKey:@"ZIP"];
    }
    
    if (self.latitude) {
        [dict setObjectOrNil:self.latitude forKey:@"LATITUDE"];
    }

    if (self.longitude) {
        [dict setObjectOrNil:self.longitude forKey:@"LONGITUDE"];
    }
    
    if ([self.telephone length] > 0) {
        [dict setObjectOrNil:self.telephone forKey:@"TELEPHONE"];
    }
    
    if ([self.webURL length] > 0) {
        [dict setObjectOrNil:self.webURL forKey:@"WEB"];
    }
    
    if ([self.businessDescription length] > 0) {
        [dict setObjectOrNil:self.businessDescription forKey:@"DESCRIPTION"];
    }
    
    return dict;
}

@end
