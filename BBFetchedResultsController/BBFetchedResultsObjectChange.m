//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsObjectChange.h"
#import "BBFetchedResultsIndexPath.h"

@implementation BBFetchedResultsObjectChange

+ (BBFetchedResultsObjectChange *)withObject:(NSManagedObject *)object priorIndexPath:(BBFetchedResultsIndexPath *)sourceIndexPath indexPath:(BBFetchedResultsIndexPath *)destinationIndexPath changeType:(BBFetchedResultsChangeType)changeType {
    BBFetchedResultsObjectChange *change = [self new];
    [change setObject:object];
    [change setPriorIndexPath:sourceIndexPath];
    [change setIndexPath:destinationIndexPath];
    [change setChangeType:changeType];
    return change;
}

+ (BBFetchedResultsObjectChange *)insertionWithObject:(NSManagedObject *)object indexPath:(BBFetchedResultsIndexPath *)indexPath {
    return [self withObject:object priorIndexPath:nil indexPath:indexPath changeType:BBFetchedResultsChangeInsert];
}

+ (BBFetchedResultsObjectChange *)deletionWithObject:(NSManagedObject *)object priorIndexPath:(BBFetchedResultsIndexPath *)priorIndexPath {
    return [self withObject:object priorIndexPath:priorIndexPath indexPath:nil changeType:BBFetchedResultsChangeDelete];
}

+ (BBFetchedResultsObjectChange *)updateWithObject:(NSManagedObject *)object indexPath:(BBFetchedResultsIndexPath *)indexPath {
    return [self withObject:object priorIndexPath:nil indexPath:indexPath changeType:BBFetchedResultsChangeUpdate];
}

+ (BBFetchedResultsObjectChange *)moveWithObject:(NSManagedObject *)object priorIndexPath:(BBFetchedResultsIndexPath *)priorIndexPath indexPath:(BBFetchedResultsIndexPath *)indexPath {
    return [self withObject:object priorIndexPath:priorIndexPath indexPath:indexPath changeType:BBFetchedResultsChangeMove];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[BBFetchedResultsObjectChange class]]) return NO;
    if ([object changeType] != [self changeType]) return NO;
    if (![[object priorIndexPath] isEqual:[self priorIndexPath]]) return NO;
    if (![[object indexPath] isEqual:[self indexPath]]) return NO;
    if (![[object object] isEqual:[self object]]) return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger result = 1;
    NSUInteger prime = 31;
    
    result = prime * result + [[self object] hash];
    result = prime * result + [[self priorIndexPath] hash];
    result = prime * result + [[self indexPath] hash];
    result = prime * result + [self changeType];
    
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ object:%@ priorIndexPath:%@ indexPath:%@ changeType:%@", [super description], [self object], [self priorIndexPath], [self indexPath], NSStringFromBBFetchedResultsChangeType([self changeType])];
}

@end
