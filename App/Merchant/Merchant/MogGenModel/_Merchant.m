// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Merchant.m instead.

#import "_Merchant.h"

const struct MerchantAttributes MerchantAttributes = {
	.businessCategory = @"businessCategory",
	.businessDescription = @"businessDescription",
	.city = @"city",
	.currency = @"currency",
	.directoryListing = @"directoryListing",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.name = @"name",
	.streetAddress = @"streetAddress",
	.telephone = @"telephone",
	.walletAddress = @"walletAddress",
	.webURL = @"webURL",
	.zipcode = @"zipcode",
};

const struct MerchantRelationships MerchantRelationships = {
};

const struct MerchantFetchedProperties MerchantFetchedProperties = {
};

@implementation MerchantID
@end

@implementation _Merchant

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Merchant" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Merchant";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Merchant" inManagedObjectContext:moc_];
}

- (MerchantID*)objectID {
	return (MerchantID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"businessCategoryValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"businessCategory"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"directoryListingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"directoryListing"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic businessCategory;



- (int16_t)businessCategoryValue {
	NSNumber *result = [self businessCategory];
	return [result shortValue];
}

- (void)setBusinessCategoryValue:(int16_t)value_ {
	[self setBusinessCategory:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveBusinessCategoryValue {
	NSNumber *result = [self primitiveBusinessCategory];
	return [result shortValue];
}

- (void)setPrimitiveBusinessCategoryValue:(int16_t)value_ {
	[self setPrimitiveBusinessCategory:[NSNumber numberWithShort:value_]];
}





@dynamic businessDescription;






@dynamic city;






@dynamic currency;






@dynamic directoryListing;



- (BOOL)directoryListingValue {
	NSNumber *result = [self directoryListing];
	return [result boolValue];
}

- (void)setDirectoryListingValue:(BOOL)value_ {
	[self setDirectoryListing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDirectoryListingValue {
	NSNumber *result = [self primitiveDirectoryListing];
	return [result boolValue];
}

- (void)setPrimitiveDirectoryListingValue:(BOOL)value_ {
	[self setPrimitiveDirectoryListing:[NSNumber numberWithBool:value_]];
}





@dynamic latitude;



- (float)latitudeValue {
	NSNumber *result = [self latitude];
	return [result floatValue];
}

- (void)setLatitudeValue:(float)value_ {
	[self setLatitude:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result floatValue];
}

- (void)setPrimitiveLatitudeValue:(float)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithFloat:value_]];
}





@dynamic longitude;



- (float)longitudeValue {
	NSNumber *result = [self longitude];
	return [result floatValue];
}

- (void)setLongitudeValue:(float)value_ {
	[self setLongitude:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result floatValue];
}

- (void)setPrimitiveLongitudeValue:(float)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithFloat:value_]];
}





@dynamic name;






@dynamic streetAddress;






@dynamic telephone;






@dynamic walletAddress;






@dynamic webURL;






@dynamic zipcode;











@end
