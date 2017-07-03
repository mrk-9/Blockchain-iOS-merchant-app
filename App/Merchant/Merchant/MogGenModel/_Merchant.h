// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Merchant.h instead.

#import <CoreData/CoreData.h>


extern const struct MerchantAttributes {
	__unsafe_unretained NSString *businessCategory;
	__unsafe_unretained NSString *businessDescription;
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *currency;
	__unsafe_unretained NSString *directoryListing;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *streetAddress;
	__unsafe_unretained NSString *telephone;
	__unsafe_unretained NSString *walletAddress;
	__unsafe_unretained NSString *webURL;
	__unsafe_unretained NSString *zipcode;
} MerchantAttributes;

extern const struct MerchantRelationships {
} MerchantRelationships;

extern const struct MerchantFetchedProperties {
} MerchantFetchedProperties;
















@interface MerchantID : NSManagedObjectID {}
@end

@interface _Merchant : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MerchantID*)objectID;





@property (nonatomic, strong) NSNumber* businessCategory;



@property int16_t businessCategoryValue;
- (int16_t)businessCategoryValue;
- (void)setBusinessCategoryValue:(int16_t)value_;

//- (BOOL)validateBusinessCategory:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* businessDescription;



//- (BOOL)validateBusinessDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* city;



//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* currency;



//- (BOOL)validateCurrency:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* directoryListing;



@property BOOL directoryListingValue;
- (BOOL)directoryListingValue;
- (void)setDirectoryListingValue:(BOOL)value_;

//- (BOOL)validateDirectoryListing:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* latitude;



@property float latitudeValue;
- (float)latitudeValue;
- (void)setLatitudeValue:(float)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property float longitudeValue;
- (float)longitudeValue;
- (void)setLongitudeValue:(float)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* streetAddress;



//- (BOOL)validateStreetAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* telephone;



//- (BOOL)validateTelephone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* walletAddress;



//- (BOOL)validateWalletAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* webURL;



//- (BOOL)validateWebURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* zipcode;



//- (BOOL)validateZipcode:(id*)value_ error:(NSError**)error_;






@end

@interface _Merchant (CoreDataGeneratedAccessors)

@end

@interface _Merchant (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBusinessCategory;
- (void)setPrimitiveBusinessCategory:(NSNumber*)value;

- (int16_t)primitiveBusinessCategoryValue;
- (void)setPrimitiveBusinessCategoryValue:(int16_t)value_;




- (NSString*)primitiveBusinessDescription;
- (void)setPrimitiveBusinessDescription:(NSString*)value;




- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;




- (NSString*)primitiveCurrency;
- (void)setPrimitiveCurrency:(NSString*)value;




- (NSNumber*)primitiveDirectoryListing;
- (void)setPrimitiveDirectoryListing:(NSNumber*)value;

- (BOOL)primitiveDirectoryListingValue;
- (void)setPrimitiveDirectoryListingValue:(BOOL)value_;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (float)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(float)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (float)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(float)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveStreetAddress;
- (void)setPrimitiveStreetAddress:(NSString*)value;




- (NSString*)primitiveTelephone;
- (void)setPrimitiveTelephone:(NSString*)value;




- (NSString*)primitiveWalletAddress;
- (void)setPrimitiveWalletAddress:(NSString*)value;




- (NSString*)primitiveWebURL;
- (void)setPrimitiveWebURL:(NSString*)value;




- (NSString*)primitiveZipcode;
- (void)setPrimitiveZipcode:(NSString*)value;




@end
