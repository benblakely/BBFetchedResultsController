// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BBPerson.h instead.

#import <CoreData/CoreData.h>


extern const struct BBPersonAttributes {
	__unsafe_unretained NSString *name;
} BBPersonAttributes;

extern const struct BBPersonRelationships {
	__unsafe_unretained NSString *toDos;
} BBPersonRelationships;

extern const struct BBPersonFetchedProperties {
} BBPersonFetchedProperties;

@class BBToDo;



@interface BBPersonID : NSManagedObjectID {}
@end

@interface _BBPerson : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BBPersonID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *toDos;

- (NSMutableSet*)toDosSet;





@end

@interface _BBPerson (CoreDataGeneratedAccessors)

- (void)addToDos:(NSSet*)value_;
- (void)removeToDos:(NSSet*)value_;
- (void)addToDosObject:(BBToDo*)value_;
- (void)removeToDosObject:(BBToDo*)value_;

@end

@interface _BBPerson (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveToDos;
- (void)setPrimitiveToDos:(NSMutableSet*)value;


@end
