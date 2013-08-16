//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsObjectInsertion.h"
#import "BBFetchedResultsIndexPath.h"

@implementation BBFetchedResultsObjectInsertion

+ (BBFetchedResultsObjectInsertion *)withObject:(NSManagedObject *)object indexPath:(BBFetchedResultsIndexPath *)indexPath {
    BBFetchedResultsObjectInsertion *insertion = [self new];
    [insertion setObject:object];
    [insertion setIndexPath:indexPath];
    return insertion;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[BBFetchedResultsObjectInsertion class]]) return NO;
    if (![[object indexPath] isEqual:[self indexPath]]) return NO;
    if (![[object object] isEqual:[self object]]) return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger result = 1;
    NSUInteger prime = 31;
    
    result = prime * result + [[self object] hash];
    result = prime * result + [[self indexPath] hash];
    
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ object:%@ indexPath:%@", [super description], [self object], [self indexPath]];
}

@end
