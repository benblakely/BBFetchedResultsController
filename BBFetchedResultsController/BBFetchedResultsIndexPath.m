//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsIndexPath.h"

@implementation BBFetchedResultsIndexPath

+ (BBFetchedResultsIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    BBFetchedResultsIndexPath *indexPath = [self new];
    [indexPath setRow:row];
    [indexPath setSection:section];
    return indexPath;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[BBFetchedResultsIndexPath class]]) return NO;
    if ([(BBFetchedResultsIndexPath *)object section] != [self section]) return NO;
    if ([(BBFetchedResultsIndexPath *)object row] != [self row]) return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger result = 1;
    NSUInteger prime = 31;
    
    result = prime * result + [self section];
    result = prime * result + [self row];
    
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ section:%d row:%d", [super description], [self section], [self row]];
}

@end
