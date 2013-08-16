//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import <Foundation/Foundation.h>

@interface BBFetchedResultsIndexPath : NSObject

@property (nonatomic) NSUInteger section;
@property (nonatomic) NSUInteger row;

+ (BBFetchedResultsIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@end
