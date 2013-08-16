//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsController.h"

@interface BBFetchedResultsObjectChange : NSObject

@property (nonatomic) NSManagedObject *object;
@property (nonatomic) BBFetchedResultsIndexPath *priorIndexPath;
@property (nonatomic) BBFetchedResultsIndexPath *indexPath;
@property (nonatomic) BBFetchedResultsChangeType changeType;

+ (BBFetchedResultsObjectChange *)insertionWithObject:(NSManagedObject *)object indexPath:(BBFetchedResultsIndexPath *)indexPath;

+ (BBFetchedResultsObjectChange *)deletionWithObject:(NSManagedObject *)object priorIndexPath:(BBFetchedResultsIndexPath *)indexPath;

+ (BBFetchedResultsObjectChange *)updateWithObject:(NSManagedObject *)object indexPath:(BBFetchedResultsIndexPath *)indexPath;;

+ (BBFetchedResultsObjectChange *)moveWithObject:(NSManagedObject *)object priorIndexPath:(BBFetchedResultsIndexPath *)sourceIndexPath indexPath:(BBFetchedResultsIndexPath *)destinationIndexPath;

@end
