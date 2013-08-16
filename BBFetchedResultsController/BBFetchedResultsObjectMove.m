//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsObjectMove.h"
#import "BBFetchedResultsIndexPath.h"

@implementation BBFetchedResultsObjectMove

+ (BBFetchedResultsObjectMove *)withObject:(NSManagedObject *)object sourceIndexPath:(BBFetchedResultsIndexPath *)sourceIndexPath destinationIndexPath:(BBFetchedResultsIndexPath *)destinationIndexPath {
    BBFetchedResultsObjectMove *move = [self new];
    [move setObject:object];
    [move setSourceIndexPath:sourceIndexPath];
    [move setDestinationIndexPath:destinationIndexPath];
    return move;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[BBFetchedResultsObjectMove class]]) return NO;
    if (![[object sourceIndexPath] isEqual:[self sourceIndexPath]]) return NO;
    if (![[object destinationIndexPath] isEqual:[self destinationIndexPath]]) return NO;
    if (![[object object] isEqual:[self object]]) return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger result = 1;
    NSUInteger prime = 31;
    
    result = prime * result + [[self object] hash];
    result = prime * result + [[self sourceIndexPath] hash];
    result = prime * result + [[self destinationIndexPath] hash];
    
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ object:%@ sourceIndexPath:%@ destinationIndexPath:%@", [super description], [self object], [self sourceIndexPath], [self destinationIndexPath]];
}

@end
