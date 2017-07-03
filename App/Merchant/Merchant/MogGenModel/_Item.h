// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Item.h instead.

#import <CoreData/CoreData.h>


extern const struct ItemAttributes {
	__unsafe_unretained NSString *active_date;
	__unsafe_unretained NSString *creation_date;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *price;
} ItemAttributes;

extern const struct ItemRelationships {
} ItemRelationships;

extern const struct ItemFetchedProperties {
} ItemFetchedProperties;







@interface ItemID : NSManagedObjectID {}
@end

@interface _Item : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ItemID*)objectID;





@property (nonatomic, strong) NSDate* active_date;



//- (BOOL)validateActive_date:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creation_date;



//- (BOOL)validateCreation_date:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* price;



@property float priceValue;
- (float)priceValue;
- (void)setPriceValue:(float)value_;

//- (BOOL)validatePrice:(id*)value_ error:(NSError**)error_;






@end

@interface _Item (CoreDataGeneratedAccessors)

@end

@interface _Item (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveActive_date;
- (void)setPrimitiveActive_date:(NSDate*)value;




- (NSDate*)primitiveCreation_date;
- (void)setPrimitiveCreation_date:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePrice;
- (void)setPrimitivePrice:(NSNumber*)value;

- (float)primitivePriceValue;
- (void)setPrimitivePriceValue:(float)value_;




@end
