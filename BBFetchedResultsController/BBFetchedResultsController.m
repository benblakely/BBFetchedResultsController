//  Copyright 2013 Ben Blakely. All rights reserved.
//  See included License file for licensing information.

#import "BBFetchedResultsController.h"
#import "BBFetchedResultsSection.h"
#import "BBFetchedResultsObjectChange.h"

@interface BBFetchedResultsController ()

@property (nonatomic) NSFetchRequest *fetchRequest;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSString *sectionNameKeyPath;
@property (nonatomic) NSArray *sectionIndexTitles;
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *fetchedObjects;
@property (nonatomic) NSArray *objectIDs;

@end

@implementation BBFetchedResultsController

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath {
    self = [super init];
    if (!self) return nil;
    
    [self setFetchRequest:fetchRequest];
    [self setManagedObjectContext:context];
    [self setSectionNameKeyPath:sectionNameKeyPath];
    
    NSManagedObjectContext *rootContext = context;
    while ([rootContext parentContext]) {
        rootContext = [rootContext parentContext];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:rootContext];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)performFetch:(NSError **)error {
    if ([self fetchedObjects]) {
        return [self updateDataWithUpdatedObjects:nil error:error];
    }
    
    NSArray *sections, *fetchedObjects, *objectIDs;
    BOOL succeeded = [self calculateSections:&sections fetchedObjects:&fetchedObjects objectIDs:&objectIDs error:error];
    if (!succeeded) return NO;
    
    [self setSections:sections];
    [self setSectionIndexTitles:nil];
    [self setFetchedObjects:fetchedObjects];
    [self setObjectIDs:objectIDs];
    
    return YES;
}

- (id)objectAtIndexPath:(BBFetchedResultsIndexPath *)indexPath {
    BBFetchedResultsSection *section = [[self sections] objectAtIndex:[indexPath section]];
    NSManagedObject *object = [[self fetchedObjects] objectAtIndex:[section range].location + [indexPath row]];
    return object;
}

- (BBFetchedResultsIndexPath *)indexPathForObject:(id)object {
    return [self indexPathForObjectID:[object objectID] objectIDs:[self objectIDs] sections:[self sections]];
}

- (BBFetchedResultsIndexPath *)indexPathForObjectID:(id)objectID objectIDs:(NSArray *)objectIDs sections:(NSArray *)sections {
    NSUInteger index = [objectIDs indexOfObject:objectID];
    if (index == NSNotFound) return nil;
    
    __block BBFetchedResultsIndexPath *indexPath;
    [sections enumerateObjectsUsingBlock:^(BBFetchedResultsSection *section, NSUInteger sectionIndex, BOOL *stop) {
        if (!NSLocationInRange(index, [section range])) return;
        NSUInteger row = index - [section range].location;
        indexPath = [BBFetchedResultsIndexPath indexPathForRow:row inSection:sectionIndex];
        *stop = YES;
    }];
    
    return indexPath;
}

- (void)enumerateObjectsFromIDs:(NSArray *)objectIDs section:(BBFetchedResultsSection *)section block:(void (^)(NSManagedObject *object, NSUInteger idx, BOOL *stop))block {
    if ([section range].length == 0) return;
    NSUInteger lastIndex = [section range].location + [section range].length - 1;
    for (NSUInteger index = [section range].location; index <= lastIndex; ++index) {
        id objectID = [objectIDs objectAtIndex:index];
        NSManagedObject *object = [[self managedObjectContext] objectWithID:objectID];
        NSUInteger indexInSection = index - [section range].location;
        BOOL stop = NO;
        block(object, indexInSection, &stop);
        if (stop) break;
    }
}

- (NSArray *)sectionIndexTitles {
    if (!_sectionIndexTitles) {
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[[self sections] count]];
        for (BBFetchedResultsSection *section in [self sections]) {
            [titles addObject:[self sectionIndexTitleForSectionName:[section name] ?: @""]];
        }
        _sectionIndexTitles = [NSArray arrayWithArray:titles];
    }
    return _sectionIndexTitles;
}

- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName {
    if ([sectionName length] == 0) return @"";
    return [[sectionName substringToIndex:1] capitalizedString];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex {
    return sectionIndex;
}

- (BBFetchedResultsSection *)sectionForName:(NSString *)name {
    return [self sectionForName:name sections:[self sections]];
}

- (BBFetchedResultsSection *)sectionForName:(NSString *)name sections:(NSArray *)sections {
    for (BBFetchedResultsSection *section in sections) {
        if (![self sectionName:[section name] equalsName:name]) continue;
        return section;
    }
    return nil;
}

- (BOOL)sectionName:(NSString *)sectionName equalsName:(NSString *)name {
    return (!sectionName && !name) || [sectionName isEqual:name];
}

NSString *NSStringFromBBFetchedResultsChangeType(BBFetchedResultsChangeType changeType) {
    switch (changeType) {
        case BBFetchedResultsChangeDelete:
            return @"BBFetchedResultsChangeDelete";
        case BBFetchedResultsChangeInsert:
            return @"BBFetchedResultsChangeInsert";
        case BBFetchedResultsChangeMove:
            return @"BBFetchedResultsChangeMove";
        case BBFetchedResultsChangeUpdate:
            return @"BBFetchedResultsChangeUpdate";
    }
}

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    
    if ([notification object] != [self managedObjectContext]) {
        NSMutableSet *objectsInContext = [NSMutableSet setWithCapacity:[updatedObjects count]];
        [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *object, BOOL *stop) {
            NSManagedObject *objectInContext = [[self managedObjectContext] objectWithID:[object objectID]];
            [objectsInContext addObject:objectInContext];
        }];
        updatedObjects = objectsInContext;
    }
    
    [self updateDataWithUpdatedObjects:updatedObjects error:nil];
}

- (BOOL)updateDataWithUpdatedObjects:(NSSet *)updatedObjects error:(NSError **)outError {
    NSArray *sections, *fetchedObjects, *objectIDs;
    NSError *error;
    BOOL succeeded = [self calculateSections:&sections fetchedObjects:&fetchedObjects objectIDs:&objectIDs error:&error];
    if (!succeeded) {
        if (outError) {
            *outError = error;
        } else {
            NSLog(@"Failed to fetch: %@", error);
        }
        return NO;
    }
    
    id<BBFetchedResultsControllerDelegate> delegate = [self delegate];
    if (![delegate respondsToSelector:@selector(controllerWillChangeContent:)] &&
        ![delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)] &&
        ![delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)] &&
        ![delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        // Delegate doesn't respond to callbacks.
        [self setSections:sections];
        [self setSectionIndexTitles:nil];
        [self setFetchedObjects:fetchedObjects];
        [self setObjectIDs:objectIDs];
        return YES;
    }
    
    NSArray *priorSections = [self sections];
    NSArray *priorObjectIDs = [self objectIDs];
    
    NSMutableIndexSet *insertedSections = [NSMutableIndexSet new];
    [sections enumerateObjectsUsingBlock:^(BBFetchedResultsSection *section, NSUInteger index, BOOL *stop) {
        BBFetchedResultsSection *existingSection = [self sectionForName:[section name] sections:priorSections];
        if (existingSection) return;
        [insertedSections addIndex:index];
    }];
    
    NSMutableIndexSet *deletedSections = [NSMutableIndexSet new];
    [priorSections enumerateObjectsUsingBlock:^(BBFetchedResultsSection *existingSection, NSUInteger index, BOOL *stop) {
        BBFetchedResultsSection *section = [self sectionForName:[existingSection name] sections:sections];
        if (section) return;
        [deletedSections addIndex:index];
    }];
    
    NSSet *objectInsertions, *objectMoves, *objectDeletions;
    [self calculateObjectInsertions:&objectInsertions objectDeletions:&objectDeletions objectMoves:&objectMoves withSections:sections priorSections:priorSections insertedSections:insertedSections deletedSections:deletedSections objectIDs:objectIDs priorObjectIDs:priorObjectIDs];
    
    NSSet *objectUpdates = [self objectUpdatesWithSections:sections priorSections:priorSections insertedSections:insertedSections deletedSections:deletedSections objectIDs:objectIDs priorObjectIDs:priorObjectIDs objectInsertions:objectInsertions objectDeletions:objectDeletions objectMoves:objectMoves updatedObjects:updatedObjects];
    
    if ([insertedSections count] == 0 &&
        [deletedSections count] == 0 &&
        [objectInsertions count] == 0 &&
        [objectMoves count] == 0 &&
        [objectDeletions count] == 0 &&
        [objectUpdates count] == 0) {
        return YES;
    }
    
    if ([delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
        [delegate controllerWillChangeContent:self];
    }
    
    [self setSections:sections];
    [self setSectionIndexTitles:nil];
    [self setFetchedObjects:fetchedObjects];
    [self setObjectIDs:objectIDs];
    
    if ([delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
        [deletedSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            BBFetchedResultsSection *section = [priorSections objectAtIndex:idx];
            [delegate controller:self didChangeSection:section atIndex:idx forChangeType:BBFetchedResultsChangeDelete];
        }];
        [insertedSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            BBFetchedResultsSection *section = [sections objectAtIndex:idx];
            [delegate controller:self didChangeSection:section atIndex:idx forChangeType:BBFetchedResultsChangeInsert];
        }];
    }
    
    if ([delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        for (BBFetchedResultsObjectChange *deletion in objectDeletions) {
            [delegate controller:self didChangeObject:[deletion object] atIndexPath:[deletion priorIndexPath] forChangeType:BBFetchedResultsChangeDelete newIndexPath:nil];
        }
        for (BBFetchedResultsObjectChange *insertion in objectInsertions) {
            [delegate controller:self didChangeObject:[insertion object] atIndexPath:nil forChangeType:BBFetchedResultsChangeInsert newIndexPath:[insertion indexPath]];
        }
        for (BBFetchedResultsObjectChange *update in objectUpdates) {
            [delegate controller:self didChangeObject:[update object] atIndexPath:[update priorIndexPath] forChangeType:BBFetchedResultsChangeUpdate newIndexPath:[update indexPath]];
        }
        for (BBFetchedResultsObjectChange *move in objectMoves) {
            [delegate controller:self didChangeObject:[move object] atIndexPath:[move priorIndexPath] forChangeType:BBFetchedResultsChangeMove newIndexPath:[move indexPath]];
        }
    }
    
    if ([delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [delegate controllerDidChangeContent:self];
    }
    
    return YES;
}

- (BOOL)calculateSections:(NSArray **)outSections fetchedObjects:(NSArray **)outFetchedObjects objectIDs:(NSArray **)outObjectIDs error:(NSError **)outError {
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:[self fetchRequest] error:&error];
    if (error) {
        if (outError) *outError = error;
        return NO;
    }
    
    NSFetchRequestResultType resultType = [[self fetchRequest] resultType];
    NSArray *relationshipKeyPaths = [[self fetchRequest] relationshipKeyPathsForPrefetching];
    
    [[self fetchRequest] setResultType:NSManagedObjectIDResultType];
    [[self fetchRequest] setRelationshipKeyPathsForPrefetching:nil];
    
    NSArray *objectIDs = [[self managedObjectContext] executeFetchRequest:[self fetchRequest] error:&error];
    
    [[self fetchRequest] setResultType:resultType];
    [[self fetchRequest] setRelationshipKeyPathsForPrefetching:relationshipKeyPaths];
    if (error) {
        if (outError) *outError = error;
        return NO;
    }
    
    if (![self sectionNameKeyPath]) {
        BBFetchedResultsSection *section = [BBFetchedResultsSection new];
        [section setRange:NSMakeRange(0, [fetchedObjects count])];
        if (outSections) *outSections = @[section];
        if (outFetchedObjects) *outFetchedObjects = fetchedObjects;
        if (outObjectIDs) *outObjectIDs = objectIDs;
        return YES;
    }
    
    NSFetchRequest *sectionFetchRequest = [NSFetchRequest fetchRequestWithEntityName:[[self fetchRequest] entityName]];
    [sectionFetchRequest setResultType:NSDictionaryResultType];
    [sectionFetchRequest setPredicate:[[self fetchRequest] predicate]];
    [sectionFetchRequest setSortDescriptors:[[self fetchRequest] sortDescriptors]];
    
    NSExpressionDescription *countDescription = [NSExpressionDescription new];
    [countDescription setName:@"count"];
    [countDescription setExpression:[NSExpression expressionForFunction:@"count:" arguments:@[[NSExpression expressionForEvaluatedObject]]]];
    [countDescription setExpressionResultType:NSInteger32AttributeType];
    
    [sectionFetchRequest setPropertiesToFetch:@[[self sectionNameKeyPath], countDescription]];
    [sectionFetchRequest setPropertiesToGroupBy:@[[self sectionNameKeyPath]]];
    
    NSArray *sectionCounts = [[self managedObjectContext] executeFetchRequest:sectionFetchRequest error:&error];
    if (error) {
        if (outError) *outError = error;
        return NO;
    }
    
    NSMutableArray *sections = [NSMutableArray array];
    NSUInteger fetchedObjectsCount = 0;
    NSUInteger offset = [[self fetchRequest] fetchOffset];
    NSUInteger limit = [[self fetchRequest] fetchLimit];
    for (NSDictionary *sectionInfo in sectionCounts) {
        NSUInteger sectionCount = [sectionInfo[@"count"] unsignedIntegerValue];
        if (offset >= sectionCount) {
            offset -= sectionCount;
            continue;
        }
        sectionCount -= offset;
        if (limit > 0) {
            sectionCount = MIN(sectionCount, limit - fetchedObjectsCount);
        }
        NSString *name = sectionInfo[[self sectionNameKeyPath]];
        BBFetchedResultsSection *section = [BBFetchedResultsSection new];
        [section setName:name];
        [section setRange:NSMakeRange(fetchedObjectsCount, sectionCount)];
        [sections addObject:section];
        fetchedObjectsCount += [section range].length;
        offset -= MIN([section range].length, offset);
        if (limit > 0 && fetchedObjectsCount == limit) break;
    }
    
    if (outSections) *outSections = [NSArray arrayWithArray:sections];
    if (outFetchedObjects) *outFetchedObjects = fetchedObjects;
    if (outObjectIDs) *outObjectIDs = objectIDs;
    return YES;
}

- (void)calculateObjectInsertions:(NSSet **)outObjectInsertions
                  objectDeletions:(NSSet **)outObjectDeletions
                      objectMoves:(NSSet **)outObjectMoves
                     withSections:(NSArray *)sections
                    priorSections:(NSArray *)priorSections
                 insertedSections:(NSIndexSet *)insertedSections
                  deletedSections:(NSIndexSet *)deletedSections
                        objectIDs:(NSArray *)objectIDs
                   priorObjectIDs:(NSArray *)priorObjectIDs
{
    NSMutableSet *objectInsertions = [NSMutableSet new];
    NSMutableSet *objectMoves = [NSMutableSet new];
    NSMutableSet *objectDeletions = [NSMutableSet new];
    
    [sections enumerateObjectsUsingBlock:^(BBFetchedResultsSection *section, NSUInteger sectionIndex, BOOL *stopSection) {
        [self enumerateObjectsFromIDs:objectIDs section:section block:^(NSManagedObject *object, NSUInteger rowIndex, BOOL *stopRow) {
            BBFetchedResultsIndexPath *indexPath = [BBFetchedResultsIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            BBFetchedResultsIndexPath *priorIndexPath = [self indexPathForObjectID:[object objectID] objectIDs:priorObjectIDs sections:priorSections];
            
            BOOL isInsertedInNewSection = !priorIndexPath && [insertedSections containsIndex:sectionIndex];
            if (isInsertedInNewSection) return;
            
            BOOL isInserted = !priorIndexPath;
            if (isInserted) {
                [objectInsertions addObject:[BBFetchedResultsObjectChange insertionWithObject:object indexPath:indexPath]];
                return;
            }
            
            BOOL hasMovedFromDeletedSection = [deletedSections containsIndex:[priorIndexPath section]];
            BOOL hasMovedToInsertedSection = [insertedSections containsIndex:sectionIndex];
            if (hasMovedFromDeletedSection && hasMovedToInsertedSection) return;
            
            if (hasMovedFromDeletedSection) {
                [objectInsertions addObject:[BBFetchedResultsObjectChange insertionWithObject:object indexPath:indexPath]];
                return;
            }
            
            if (hasMovedToInsertedSection) {
                [objectDeletions addObject:[BBFetchedResultsObjectChange deletionWithObject:object priorIndexPath:priorIndexPath]];
                return;
            }
            
            BBFetchedResultsSection *priorSection = [priorSections objectAtIndex:[priorIndexPath section]];
            
            BOOL hasMovedSections = ![self sectionName:[section name] equalsName:[priorSection name]];
            if (hasMovedSections) {
                [objectMoves addObject:[BBFetchedResultsObjectChange moveWithObject:object priorIndexPath:priorIndexPath indexPath:indexPath]];
                return;
            }
            
            BOOL hasMovedWithinSection = [priorIndexPath row] != [indexPath row];
            if (!hasMovedWithinSection) return;
            
            [objectMoves addObject:[BBFetchedResultsObjectChange moveWithObject:object priorIndexPath:priorIndexPath indexPath:indexPath]];
        }];
    }];
    
    // Find deletions.
    [priorSections enumerateObjectsUsingBlock:^(BBFetchedResultsSection *section, NSUInteger sectionIndex, BOOL *stopSection) {
        [self enumerateObjectsFromIDs:priorObjectIDs section:section block:^(NSManagedObject *object, NSUInteger rowIndex, BOOL *stopRow) {
            if ([objectIDs containsObject:[object objectID]]) return;
            if ([deletedSections containsIndex:sectionIndex]) return;
            
            BBFetchedResultsIndexPath *priorIndexPath = [BBFetchedResultsIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            [objectDeletions addObject:[BBFetchedResultsObjectChange deletionWithObject:object priorIndexPath:priorIndexPath]];
        }];
    }];
    
    // Remove unnecessary moves (i.e. those that are implied by other insertions, deletions and moves).
    NSMutableSet *impliedMoves = [NSMutableSet new];
    for (BBFetchedResultsObjectChange *move in objectMoves) {
        BBFetchedResultsIndexPath *indexPath = [move indexPath];
        BBFetchedResultsIndexPath *priorIndexPath = [move priorIndexPath];
        BBFetchedResultsSection *section = [sections objectAtIndex:[indexPath section]];
        BBFetchedResultsSection *priorSection = [priorSections objectAtIndex:[priorIndexPath section]];
        
        BOOL hasMovedSections = ![self sectionName:[section name] equalsName:[priorSection name]];
        if (hasMovedSections) continue;
        
        BOOL hasMoved = [priorIndexPath row] != [indexPath row];
        if (!hasMoved) {
            [impliedMoves addObject:move];
            continue;
        }
        
        NSUInteger insertionsAboveCount = 0;
        if ([indexPath row] > 0) {
            for (BBFetchedResultsObjectChange *insertion in objectInsertions) {
                if ([[insertion indexPath] section] != [indexPath section]) continue;
                if ([[insertion indexPath] row] > [indexPath row]) continue;
                insertionsAboveCount++;
            }
        }
        
        NSUInteger deletionsAboveCount = 0;
        if ([priorIndexPath row] > 0) {
            for (BBFetchedResultsObjectChange *deletion in objectDeletions) {
                if ([[deletion indexPath] section] != [priorIndexPath section]) continue;
                if ([[deletion indexPath] row] > [priorIndexPath row]) continue;
                deletionsAboveCount++;
            }
        }
        
        NSUInteger movesFromAboveCount = 0;
        NSUInteger movesToAboveCount = 0;
        for (BBFetchedResultsObjectChange *siblingMove in objectMoves) {
            if (siblingMove == move) continue;
            
            BOOL hasSiblingMovedSections = [[siblingMove priorIndexPath] section] != [[siblingMove indexPath] section];
            if (hasSiblingMovedSections) {
                BOOL movedFromAbove = [[siblingMove priorIndexPath] section] == [[move priorIndexPath] section] && [[siblingMove priorIndexPath] row] < [[move priorIndexPath] row];
                BOOL movedToAbove = [[siblingMove indexPath] section] == [[move indexPath] section] && [[siblingMove indexPath] row] < [[move indexPath] row];
                if (movedFromAbove && movedToAbove) continue;
                
                if (movedFromAbove) {
                    movesFromAboveCount++;
                } else if (movesToAboveCount) {
                    movesToAboveCount++;
                }
                continue;
            }
            
            if ([[siblingMove indexPath] section] != [[move indexPath] section]) continue;
            
            BOOL movedFromAbove = [[siblingMove priorIndexPath] row] < [[move priorIndexPath] row];
            BOOL movedToAbove = [[siblingMove indexPath] row] < [[move indexPath] row];
            if (movedFromAbove && movedToAbove) continue;
            
            if (movedFromAbove) {
                movesFromAboveCount++;
            } else if (movesToAboveCount) {
                movesToAboveCount++;
            }
        }
        
        NSUInteger impliedRow = [priorIndexPath row] + insertionsAboveCount - deletionsAboveCount + movesToAboveCount - movesFromAboveCount;
        if (impliedRow != [indexPath row]) continue;
        
        [impliedMoves addObject:move];
    }
    [objectMoves minusSet:impliedMoves];
    
    if (outObjectInsertions) *outObjectInsertions = objectInsertions;
    if (outObjectDeletions) *outObjectDeletions = objectDeletions;
    if (outObjectMoves) *outObjectMoves = objectMoves;
}

- (NSSet *)objectUpdatesWithSections:(NSArray *)sections
                       priorSections:(NSArray *)priorSections
                    insertedSections:(NSIndexSet *)insertedSections
                     deletedSections:(NSIndexSet *)deletedSections
                           objectIDs:(NSArray *)objectIDs
                      priorObjectIDs:(NSArray *)priorObjectIDs
                    objectInsertions:(NSSet *)objectInsertions
                     objectDeletions:(NSSet *)objectDeletions
                         objectMoves:(NSSet *)objectMoves
                      updatedObjects:(NSSet *)updatedObjects
{
    if ([updatedObjects count] == 0) return [NSSet new];
    
    NSMutableSet *alreadyHandledObjects = [NSMutableSet new];
    [alreadyHandledObjects unionSet:[objectInsertions valueForKeyPath:@"object"]];
    [alreadyHandledObjects unionSet:[objectDeletions valueForKeyPath:@"object"]];
    [alreadyHandledObjects unionSet:[objectMoves valueForKeyPath:@"object"]];
    
    NSMutableSet *objectUpdates = [NSMutableSet new];
    NSArray *relationshipKeyPaths = [[self fetchRequest] relationshipKeyPathsForPrefetching];
    
    for (NSManagedObject *updatedObject in updatedObjects) {
        if ([alreadyHandledObjects containsObject:updatedObject]) continue;
        
        if ([objectIDs containsObject:[updatedObject objectID]]) {
            BBFetchedResultsIndexPath *indexPath = [self indexPathForObjectID:[updatedObject objectID] objectIDs:objectIDs sections:sections];
            if ([insertedSections containsIndex:[indexPath section]]) continue;
            BBFetchedResultsIndexPath *priorIndexPath = [self indexPathForObjectID:[updatedObject objectID] objectIDs:priorObjectIDs sections:priorSections];
            if (priorIndexPath && [deletedSections containsIndex:[priorIndexPath section]]) continue;
            [objectUpdates addObject:[BBFetchedResultsObjectChange updateWithObject:updatedObject priorIndexPath:priorIndexPath indexPath:indexPath]];
            [alreadyHandledObjects addObject:updatedObject];
            continue;
        }
        
        if ([relationshipKeyPaths count] == 0) continue;
        
        [sections enumerateObjectsUsingBlock:^(BBFetchedResultsSection *section, NSUInteger sectionIndex, BOOL *stopSection) {
            [self enumerateObjectsFromIDs:objectIDs section:section block:^(NSManagedObject *object, NSUInteger rowIndex, BOOL *stopRow) {
                if ([object isFault]) return;
                NSString *keyPath;
                for (keyPath in relationshipKeyPaths) {
                    NSManagedObject *relatedObject = [object valueForKeyPath:keyPath];
                    if (updatedObject == relatedObject) break;
                    keyPath = nil;
                }
                if (!keyPath) return;
                if ([alreadyHandledObjects containsObject:object]) return;
                BBFetchedResultsIndexPath *indexPath = [BBFetchedResultsIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                if ([insertedSections containsIndex:[indexPath section]]) return;
                BBFetchedResultsIndexPath *priorIndexPath = [self indexPathForObjectID:[object objectID] objectIDs:priorObjectIDs sections:priorSections];
                if (priorIndexPath && [deletedSections containsIndex:[priorIndexPath section]]) return;
                [objectUpdates addObject:[BBFetchedResultsObjectChange updateWithObject:object priorIndexPath:priorIndexPath indexPath:indexPath]];
                [alreadyHandledObjects addObject:object];
                *stopSection = YES;
            }];
        }];
    }
    
    return objectUpdates;
}

@end
