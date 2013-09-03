//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import <Foundation/Foundation.h>

@interface BBFetchedResultsIndexPath : NSIndexPath

@property (nonatomic, readonly) NSInteger section;
@property (nonatomic, readonly) NSInteger row;
@property (nonatomic, readonly) NSInteger item;

+ (BBFetchedResultsIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;
+ (BBFetchedResultsIndexPath *)indexPathForItem:(NSInteger)item inSection:(NSInteger)section;

@end
