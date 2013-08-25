//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import <Foundation/Foundation.h>

@interface BBFetchedResultsIndexPath : NSObject

@property (nonatomic) NSInteger section;
@property (nonatomic) NSInteger row;

+ (BBFetchedResultsIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@end
