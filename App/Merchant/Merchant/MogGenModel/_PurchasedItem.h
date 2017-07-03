// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PurchasedItem.h instead.

#import <CoreData/CoreData.h>


extern const struct PurchasedItemAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *price;
} PurchasedItemAttributes;

extern const struct PurchasedItemRelationships {
	__unsafe_unretained NSString *transaction;
} PurchasedItemRelationships;

extern const struct PurchasedItemFetchedProperties {
} PurchasedItemFetchedProperties;

@class Transaction;




@interface PurchasedItemID : NSManagedObjectID {}
@end

@interface _PurchasedItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PurchasedItemID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* price;



@property float priceValue;
- (float)priceValue;
- (void)setPriceValue:(float)value_;

//- (BOOL)validatePrice:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Transaction *transaction;

//- (BOOL)validateTransaction:(id*)value_ error:(NSError**)error_;





@end

@interface _PurchasedItem (CoreDataGeneratedAccessors)

@end

@interface _PurchasedItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePrice;
- (void)setPrimitivePrice:(NSNumber*)value;

- (float)primitivePriceValue;
- (void)setPrimitivePriceValue:(float)value_;





- (Transaction*)primitiveTransaction;
- (void)setPrimitiveTransaction:(Transaction*)value;


@end
