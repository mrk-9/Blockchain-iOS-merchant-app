// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PurchasedItem.m instead.

#import "_PurchasedItem.h"

const struct PurchasedItemAttributes PurchasedItemAttributes = {
	.name = @"name",
	.price = @"price",
};

const struct PurchasedItemRelationships PurchasedItemRelationships = {
	.transaction = @"transaction",
};

const struct PurchasedItemFetchedProperties PurchasedItemFetchedProperties = {
};

@implementation PurchasedItemID
@end

@implementation _PurchasedItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"PurchasedItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"PurchasedItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"PurchasedItem" inManagedObjectContext:moc_];
}

- (PurchasedItemID*)objectID {
	return (PurchasedItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"priceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"price"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic name;






@dynamic price;



- (float)priceValue {
	NSNumber *result = [self price];
	return [result floatValue];
}

- (void)setPriceValue:(float)value_ {
	[self setPrice:[NSNumber numberWithFloat:value_]];
}

- (float)primitivePriceValue {
	NSNumber *result = [self primitivePrice];
	return [result floatValue];
}

- (void)setPrimitivePriceValue:(float)value_ {
	[self setPrimitivePrice:[NSNumber numberWithFloat:value_]];
}





@dynamic transaction;

	






@end
