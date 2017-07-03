// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Transaction.m instead.

#import "_Transaction.h"

const struct TransactionAttributes TransactionAttributes = {
	.bitcoinAmount = @"bitcoinAmount",
	.creation_date = @"creation_date",
	.transactionHash = @"transactionHash",
};

const struct TransactionRelationships TransactionRelationships = {
	.purchasedItems = @"purchasedItems",
};

const struct TransactionFetchedProperties TransactionFetchedProperties = {
};

@implementation TransactionID
@end

@implementation _Transaction

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Transaction";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc_];
}

- (TransactionID*)objectID {
	return (TransactionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"bitcoinAmountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bitcoinAmount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic bitcoinAmount;



- (float)bitcoinAmountValue {
	NSNumber *result = [self bitcoinAmount];
	return [result floatValue];
}

- (void)setBitcoinAmountValue:(float)value_ {
	[self setBitcoinAmount:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveBitcoinAmountValue {
	NSNumber *result = [self primitiveBitcoinAmount];
	return [result floatValue];
}

- (void)setPrimitiveBitcoinAmountValue:(float)value_ {
	[self setPrimitiveBitcoinAmount:[NSNumber numberWithFloat:value_]];
}





@dynamic creation_date;






@dynamic transactionHash;






@dynamic purchasedItems;

	
- (NSMutableSet*)purchasedItemsSet {
	[self willAccessValueForKey:@"purchasedItems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"purchasedItems"];
  
	[self didAccessValueForKey:@"purchasedItems"];
	return result;
}
	






@end
