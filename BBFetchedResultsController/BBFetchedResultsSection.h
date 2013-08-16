//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsController.h"

@interface BBFetchedResultsSection : NSObject<BBFetchedResultsSectionInfo>

@property (nonatomic) NSString *indexTitle;
@property (nonatomic) NSString *name;
@property (nonatomic) NSRange range;

@end
