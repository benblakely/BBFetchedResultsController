// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BBPerson.m instead.

#import "_BBPerson.h"

const struct BBPersonAttributes BBPersonAttributes = {
	.name = @"name",
};

const struct BBPersonRelationships BBPersonRelationships = {
	.toDos = @"toDos",
};

const struct BBPersonFetchedProperties BBPersonFetchedProperties = {
};

@implementation BBPersonID
@end

@implementation _BBPerson

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Person";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc_];
}

- (BBPersonID*)objectID {
	return (BBPersonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic toDos;

	
- (NSMutableSet*)toDosSet {
	[self willAccessValueForKey:@"toDos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"toDos"];
  
	[self didAccessValueForKey:@"toDos"];
	return result;
}
	






@end
