// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BBList.h instead.

#import <CoreData/CoreData.h>


extern const struct BBListAttributes {
	__unsafe_unretained NSString *name;
} BBListAttributes;

extern const struct BBListRelationships {
	__unsafe_unretained NSString *toDos;
} BBListRelationships;

extern const struct BBListFetchedProperties {
} BBListFetchedProperties;

@class BBToDo;



@interface BBListID : NSManagedObjectID {}
@end

@interface _BBList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BBListID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *toDos;

- (NSMutableOrderedSet*)toDosSet;





@end

@interface _BBList (CoreDataGeneratedAccessors)

- (void)addToDos:(NSOrderedSet*)value_;
- (void)removeToDos:(NSOrderedSet*)value_;
- (void)addToDosObject:(BBToDo*)value_;
- (void)removeToDosObject:(BBToDo*)value_;

@end

@interface _BBList (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableOrderedSet*)primitiveToDos;
- (void)setPrimitiveToDos:(NSMutableOrderedSet*)value;


@end
