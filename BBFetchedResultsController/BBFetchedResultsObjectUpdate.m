//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsObjectUpdate.h"
#import "BBFetchedResultsIndexPath.h"

@implementation BBFetchedResultsObjectUpdate

+ (BBFetchedResultsObjectUpdate *)withObject:(NSManagedObject *)object indexPath:(BBFetchedResultsIndexPath *)indexPath {
    BBFetchedResultsObjectUpdate *update = [self new];
    [update setObject:object];
    [update setIndexPath:indexPath];
    return update;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[BBFetchedResultsObjectUpdate class]]) return NO;
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
