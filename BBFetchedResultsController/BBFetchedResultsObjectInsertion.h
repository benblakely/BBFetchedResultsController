//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBFetchedResultsIndexPath;

@interface BBFetchedResultsObjectInsertion : NSObject

@property (nonatomic) NSManagedObject *object;
@property (nonatomic) BBFetchedResultsIndexPath *indexPath;

+ (BBFetchedResultsObjectInsertion *)withObject:(NSManagedObject *)object indexPath:(BBFetchedResultsIndexPath *)indexPath;

@end
