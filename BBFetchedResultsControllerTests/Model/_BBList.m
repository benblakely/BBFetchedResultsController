// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BBList.m instead.

#import "_BBList.h"

const struct BBListAttributes BBListAttributes = {
	.name = @"name",
};

const struct BBListRelationships BBListRelationships = {
	.toDos = @"toDos",
};

const struct BBListFetchedProperties BBListFetchedProperties = {
};

@implementation BBListID
@end

@implementation _BBList

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"List";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"List" inManagedObjectContext:moc_];
}

- (BBListID*)objectID {
	return (BBListID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic toDos;

	
- (NSMutableOrderedSet*)toDosSet {
	[self willAccessValueForKey:@"toDos"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"toDos"];
  
	[self didAccessValueForKey:@"toDos"];
	return result;
}
	






@end
