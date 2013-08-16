//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBFetchedResultsIndexPath;

@interface BBFetchedResultsObjectMove : NSObject

@property (nonatomic) NSManagedObject *object;
@property (nonatomic) BBFetchedResultsIndexPath *sourceIndexPath;
@property (nonatomic) BBFetchedResultsIndexPath *destinationIndexPath;

+ (BBFetchedResultsObjectMove *)withObject:(NSManagedObject *)object sourceIndexPath:(BBFetchedResultsIndexPath *)sourceIndexPath destinationIndexPath:(BBFetchedResultsIndexPath *)destinationIndexPath;

@end
