// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Transaction.h instead.

#import <CoreData/CoreData.h>


extern const struct TransactionAttributes {
	__unsafe_unretained NSString *bitcoinAmount;
	__unsafe_unretained NSString *creation_date;
	__unsafe_unretained NSString *transactionHash;
} TransactionAttributes;

extern const struct TransactionRelationships {
	__unsafe_unretained NSString *purchasedItems;
} TransactionRelationships;

extern const struct TransactionFetchedProperties {
} TransactionFetchedProperties;

@class PurchasedItem;





@interface TransactionID : NSManagedObjectID {}
@end

@interface _Transaction : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TransactionID*)objectID;





@property (nonatomic, strong) NSNumber* bitcoinAmount;



@property float bitcoinAmountValue;
- (float)bitcoinAmountValue;
- (void)setBitcoinAmountValue:(float)value_;

//- (BOOL)validateBitcoinAmount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creation_date;



//- (BOOL)validateCreation_date:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* transactionHash;



//- (BOOL)validateTransactionHash:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *purchasedItems;

- (NSMutableSet*)purchasedItemsSet;





@end

@interface _Transaction (CoreDataGeneratedAccessors)

- (void)addPurchasedItems:(NSSet*)value_;
- (void)removePurchasedItems:(NSSet*)value_;
- (void)addPurchasedItemsObject:(PurchasedItem*)value_;
- (void)removePurchasedItemsObject:(PurchasedItem*)value_;

@end

@interface _Transaction (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBitcoinAmount;
- (void)setPrimitiveBitcoinAmount:(NSNumber*)value;

- (float)primitiveBitcoinAmountValue;
- (void)setPrimitiveBitcoinAmountValue:(float)value_;




- (NSDate*)primitiveCreation_date;
- (void)setPrimitiveCreation_date:(NSDate*)value;




- (NSString*)primitiveTransactionHash;
- (void)setPrimitiveTransactionHash:(NSString*)value;





- (NSMutableSet*)primitivePurchasedItems;
- (void)setPrimitivePurchasedItems:(NSMutableSet*)value;


@end
