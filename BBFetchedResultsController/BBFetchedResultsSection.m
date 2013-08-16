//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsSection.h"

@implementation BBFetchedResultsSection

- (NSUInteger)numberOfObjects {
    return [self range].length;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ name:%@ range:%@", [super description], [self name], NSStringFromRange([self range])];
}

@end
