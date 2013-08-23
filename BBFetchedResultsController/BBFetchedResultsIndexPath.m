//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsIndexPath.h"

@implementation BBFetchedResultsIndexPath

+ (BBFetchedResultsIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    NSUInteger indexes[] = {section, row};
    BBFetchedResultsIndexPath *indexPath = [self indexPathWithIndexes:indexes length:2];
    return indexPath;
}

+ (BBFetchedResultsIndexPath *)indexPathForItem:(NSInteger)item inSection:(NSInteger)section {
    return [self indexPathForRow:item inSection:section];
}

- (NSInteger)section {
    if ([self length] < 1) return NSNotFound;
    return [self indexAtPosition:0];
}

- (NSInteger)row {
    if ([self length] < 2) return NSNotFound;
    return [self indexAtPosition:1];
}

- (NSInteger)item {
    return [self row];
}

@end
