// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BBToDo.h instead.

#import <CoreData/CoreData.h>


extern const struct BBToDoAttributes {
	__unsafe_unretained NSString *completed;
	__unsafe_unretained NSString *name;
} BBToDoAttributes;

extern const struct BBToDoRelationships {
	__unsafe_unretained NSString *assignee;
	__unsafe_unretained NSString *list;
} BBToDoRelationships;

extern const struct BBToDoFetchedProperties {
} BBToDoFetchedProperties;

@class BBPerson;
@class BBList;




@interface BBToDoID : NSManagedObjectID {}
@end

@interface _BBToDo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BBToDoID*)objectID;





@property (nonatomic, strong) NSNumber* completed;



@property BOOL completedValue;
- (BOOL)completedValue;
- (void)setCompletedValue:(BOOL)value_;

//- (BOOL)validateCompleted:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) BBPerson *assignee;

//- (BOOL)validateAssignee:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) BBList *list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;





@end

@interface _BBToDo (CoreDataGeneratedAccessors)

@end

@interface _BBToDo (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCompleted;
- (void)setPrimitiveCompleted:(NSNumber*)value;

- (BOOL)primitiveCompletedValue;
- (void)setPrimitiveCompletedValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (BBPerson*)primitiveAssignee;
- (void)setPrimitiveAssignee:(BBPerson*)value;



- (BBList*)primitiveList;
- (void)setPrimitiveList:(BBList*)value;


@end
