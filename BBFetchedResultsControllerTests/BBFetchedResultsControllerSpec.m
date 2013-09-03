#import "Kiwi.h"
#import <CoreData/CoreData.h>
#import "BBFetchedResultsController.h"
#import "BBEntities.h"
#import "BBNonFineGrainedDelegate.h"

@interface BBFetchedResultsController ()

@property (nonatomic) NSArray *objectIDs;

@end

SPEC_BEGIN(BBFetchedResultsControllerSpec)

describe(@"BBFetchedResultsController", ^{
    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    [[NSFileManager defaultManager] createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
    NSURL *storeURL = [directory URLByAppendingPathComponent:@"BBFetchedResultsController.sqlite"];
    __block NSManagedObjectContext *managedObjectContext;
    
    beforeEach(^{
        NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"DataModel" withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        
        NSArray *data = @[
            @{@"name": @"Get milk", @"list": @"Groceries", @"assignee": @"Me"},
            
            @{@"name": @"Buy present", @"list": @"Party"},
            @{@"name": @"Send out invitations", @"list": @"Party", @"assignee": @"Me"},
            
            @{@"name": @"Bake bread", @"list": @"Personal", @"assignee": @"Me"},
            @{@"name": @"Buy car", @"list": @"Personal", @"assignee": @"Me"},
            @{@"name": @"Go for run", @"list": @"Personal", @"assignee": @"Jim"},
            @{@"name": @"Go to gym", @"list": @"Personal", @"assignee": @"Me"},
            @{@"name": @"Make dentist appointment", @"list": @"Personal", @"assignee": @"Ellen"},
            @{@"name": @"Rake lawn", @"list": @"Personal", @"assignee": @"Jim"},
            @{@"name": @"Renew membership", @"list": @"Personal", @"assignee": @"Ellen"},
            @{@"name": @"Sell house", @"list": @"Personal", @"assignee": @"Me"},
            @{@"name": @"Take out trash", @"list": @"Personal", @"assignee": @"Jim"},
            @{@"name": @"Walk dog", @"list": @"Personal", @"assignee": @"Me"},
            @{@"name": @"Workout", @"list": @"Personal", @"assignee": @"Me"},
            
            @{@"name": @"Book flight", @"list": @"Vacation"},
            @{@"name": @"Book hotel", @"list": @"Vacation"},
            
            @{@"name": @"File tax return", @"list": @"Work", @"assignee": @"Me"},
            @{@"name": @"Hire researcher", @"list": @"Work", @"assignee": @"Me"},
            @{@"name": @"Publish article", @"list": @"Work", @"assignee": @"Howard"},
        ];

        for (NSDictionary *row in data) {
            BBToDo *toDo = [BBToDo insertInManagedObjectContext:managedObjectContext];
            [toDo setName:row[@"name"]];
            
            NSString *listName = row[@"list"];
            if (listName) {
                NSFetchRequest *listRequest = [NSFetchRequest fetchRequestWithEntityName:[BBList entityName]];
                [listRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", listName]];
                [listRequest setFetchLimit:1];
                BBList *list = [[managedObjectContext executeFetchRequest:listRequest error:nil] lastObject];
                if (!list) {
                    list = [BBList insertInManagedObjectContext:managedObjectContext];
                    [list setName:listName];
                }
                [toDo setList:list];
            }
            
            NSString *assigneeName = row[@"assignee"];
            if (assigneeName) {
                NSFetchRequest *personRequest = [NSFetchRequest fetchRequestWithEntityName:[BBPerson entityName]];
                [personRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", assigneeName]];
                [personRequest setFetchLimit:1];
                BBPerson *person = [[managedObjectContext executeFetchRequest:personRequest error:nil] lastObject];
                if (!person) {
                    person = [BBPerson insertInManagedObjectContext:managedObjectContext];
                    [person setName:assigneeName];
                }
                [toDo setAssignee:person];
            }
        }
        NSError *error;
        [[theValue([managedObjectContext save:&error]) should] beTrue];
    });
    
    context(@"Without sections", ^{
        __block BBFetchedResultsController *controller;
        __block KWMock<BBFetchedResultsControllerDelegate> *delegate;
        beforeEach(^{
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"completed == NO"]];
            NSSortDescriptor *byTaskName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [request setSortDescriptors:@[byTaskName]];
            [request setRelationshipKeyPathsForPrefetching:@[@"assignee"]];
            [request setFetchBatchSize:10];
            
            controller = [[BBFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil];
            delegate = [KWMock mockForProtocol:@protocol(BBFetchedResultsControllerDelegate)];
            [controller setDelegate:delegate];
            [[theValue([controller performFetch:nil]) should] beTrue];
        });
        
        it(@"should have one section with all objects", ^{
            [[[controller should] have:1] sections];
            id section = [[controller sections] objectAtIndex:0];
            [[theValue([section numberOfObjects]) should] equal:theValue(19)];
        });
        
        it(@"should remove rows when items no longer meet predicate", ^{
            [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
            [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [BBFetchedResultsIndexPath indexPathForRow:1 inSection:0], theValue(BBFetchedResultsChangeDelete), nil];
            [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [BBFetchedResultsIndexPath indexPathForRow:2 inSection:0], theValue(BBFetchedResultsChangeDelete), nil];
            [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"list.name == 'Vacation'"]];
            NSArray *toDos = [managedObjectContext executeFetchRequest:request error:nil];
            for (BBToDo *toDo in toDos) {
                [toDo setCompletedValue:YES];
            }
            [managedObjectContext save:nil];
        });
        
        it(@"should insert row when adding new item", ^{
            [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
            [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), nil, theValue(BBFetchedResultsChangeInsert), [BBFetchedResultsIndexPath indexPathForRow:10 inSection:0]];
            [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
            
            BBToDo *toDo = [BBToDo insertInManagedObjectContext:managedObjectContext];
            [toDo setName:@"Make breakfast"];
            [managedObjectContext save:nil];
        });
        
        it(@"should move object when updating value affecting sort descriptor", ^{
            [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
            [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [BBFetchedResultsIndexPath indexPathForRow:3 inSection:0], theValue(BBFetchedResultsChangeMove), [BBFetchedResultsIndexPath indexPathForRow:9 inSection:0], nil];
            [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"name == 'Buy car'"]];
            [request setFetchLimit:1];
            BBToDo *toDo = [[managedObjectContext executeFetchRequest:request error:nil] lastObject];
            [toDo setName:@"Lease car"];
            
            [managedObjectContext save:nil];
        });
        
        it(@"should delete all rows but still have section when deleting all objects", ^{
            [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
            for (NSInteger row = 0; row <= 18; ++row) {
                [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [BBFetchedResultsIndexPath indexPathForRow:row inSection:0], theValue(BBFetchedResultsChangeDelete), nil];
            }
            [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
            NSArray *toDos = [managedObjectContext executeFetchRequest:request error:nil];
            for (BBToDo *toDo in toDos) {
                [managedObjectContext deleteObject:toDo];
            }
            
            [managedObjectContext save:nil];
            
            [[[controller should] have:1] sections];
            id section = [[controller sections] objectAtIndex:0];
            [[theValue([section numberOfObjects]) should] equal:theValue(0)];
        });
    });

    context(@"With sections", ^{
        __block BBFetchedResultsController *controller;
        __block KWMock<BBFetchedResultsControllerDelegate> *delegate;
        beforeEach(^{
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"completed == NO"]];
            NSSortDescriptor *byListName = [NSSortDescriptor sortDescriptorWithKey:@"list.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSSortDescriptor *byTaskName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [request setSortDescriptors:@[byListName, byTaskName]];
            [request setRelationshipKeyPathsForPrefetching:@[@"assignee"]];
            [request setFetchBatchSize:10];
            
            controller = [[BBFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"list.name"];
        });
        
        context(@"Wants fine-grained callbacks", ^{
            beforeEach(^{
                delegate = [KWMock mockForProtocol:@protocol(BBFetchedResultsControllerDelegate)];
                [controller setDelegate:delegate];
                [[theValue([controller performFetch:nil]) should] beTrue];
            });
            
            it(@"should remove section when deleting all items in section", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controller:didChangeSection:atIndex:forChangeType:) withArguments:controller, any(), theValue(3), theValue(BBFetchedResultsChangeDelete), nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"list.name == 'Vacation'"]];
                NSArray *toDos = [managedObjectContext executeFetchRequest:request error:nil];
                for (BBToDo *toDo in toDos) {
                    [managedObjectContext deleteObject:toDo];
                }
                [managedObjectContext save:nil];
            });        

            it(@"should remove section when all items in section no longer meet predicate", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controller:didChangeSection:atIndex:forChangeType:) withArguments:controller, any(), theValue(3), theValue(BBFetchedResultsChangeDelete), nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"list.name == 'Vacation'"]];
                NSArray *toDos = [managedObjectContext executeFetchRequest:request error:nil];
                for (BBToDo *toDo in toDos) {
                    [toDo setCompletedValue:YES];
                }
                [managedObjectContext save:nil];
            });

            it(@"should insert section when adding new item without section name", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controller:didChangeSection:atIndex:forChangeType:) withArguments:controller, any(), theValue(0), theValue(BBFetchedResultsChangeInsert), nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                
                BBToDo *toDo = [BBToDo insertInManagedObjectContext:managedObjectContext];
                [toDo setName:@"Make breakfast"];
                [managedObjectContext save:nil];
            });
            
            it(@"should move object when switching section", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [BBFetchedResultsIndexPath indexPathForRow:6 inSection:2], theValue(BBFetchedResultsChangeMove), [BBFetchedResultsIndexPath indexPathForRow:2 inSection:3], nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                
                NSFetchRequest *listRequest = [NSFetchRequest fetchRequestWithEntityName:[BBList entityName]];
                [listRequest setPredicate:[NSPredicate predicateWithFormat:@"name == 'Vacation'"]];
                [listRequest setFetchLimit:1];
                BBList *list = [[managedObjectContext executeFetchRequest:listRequest error:nil] lastObject];
                
                NSFetchRequest *toDoRequest = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
                [toDoRequest setPredicate:[NSPredicate predicateWithFormat:@"name == 'Renew membership'"]];
                [toDoRequest setFetchLimit:1];
                BBToDo *toDo = [[managedObjectContext executeFetchRequest:toDoRequest error:nil] lastObject];
                [toDo setList:list];
                
                [managedObjectContext save:nil];
            });

            it(@"should move object within section", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [BBFetchedResultsIndexPath indexPathForRow:1 inSection:2], theValue(BBFetchedResultsChangeMove), [BBFetchedResultsIndexPath indexPathForRow:3 inSection:2], nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"name == 'Buy car'"]];
                [request setFetchLimit:1];
                BBToDo *toDo = [[managedObjectContext executeFetchRequest:request error:nil] lastObject];
                [toDo setName:@"Lease car"];
                
                [managedObjectContext save:nil];
            });

            it(@"should insert object when moved from deleted section", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controller:didChangeSection:atIndex:forChangeType:) withArguments:controller, any(), theValue(0), theValue(BBFetchedResultsChangeDelete), nil];
                [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [KWNull null], theValue(BBFetchedResultsChangeInsert), [BBFetchedResultsIndexPath indexPathForRow:1 inSection:0], nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                
                NSFetchRequest *listRequest = [NSFetchRequest fetchRequestWithEntityName:[BBList entityName]];
                [listRequest setPredicate:[NSPredicate predicateWithFormat:@"name == 'Party'"]];
                [listRequest setFetchLimit:1];
                BBList *list = [[managedObjectContext executeFetchRequest:listRequest error:nil] lastObject];
                            
                NSFetchRequest *toDoRequest = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
                [toDoRequest setPredicate:[NSPredicate predicateWithFormat:@"name == 'Get milk'"]];
                [toDoRequest setFetchLimit:1];
                BBToDo *toDo = [[managedObjectContext executeFetchRequest:toDoRequest error:nil] lastObject];
                [toDo setList:list];
                
                [managedObjectContext save:nil];
            });
            
            it(@"should remove section after changing predicate", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controller:didChangeSection:atIndex:forChangeType:) withArguments:controller, any(), theValue(3), theValue(BBFetchedResultsChangeDelete), nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                
                NSFetchRequest *request = [controller fetchRequest];
                NSPredicate *existingPredicate = [request predicate];
                NSPredicate *filterOutVacactionPredicate = [NSPredicate predicateWithFormat:@"list.name != 'Vacation'"];
                [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[existingPredicate, filterOutVacactionPredicate]]];
                [controller performFetch:nil];
            });
        });
        
        context(@"Does not want fine-grained callbacks", ^{
            beforeEach(^{
                delegate = [BBNonFineGrainedDelegate mock];
                [controller setDelegate:delegate];
                [[theValue([controller performFetch:nil]) should] beTrue];
            });
            
            it(@"should not receive fine-grained callbacks", ^{
                [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
                [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
                [[delegate shouldNot] receive:@selector(controller:didChangeSection:atIndex:forChangeType:)];
                [[delegate shouldNot] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)];
                
                NSFetchRequest *listRequest = [NSFetchRequest fetchRequestWithEntityName:[BBList entityName]];
                [listRequest setPredicate:[NSPredicate predicateWithFormat:@"name == 'Party'"]];
                [listRequest setFetchLimit:1];
                BBList *list = [[managedObjectContext executeFetchRequest:listRequest error:nil] lastObject];
                
                NSFetchRequest *toDoRequest = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
                [toDoRequest setPredicate:[NSPredicate predicateWithFormat:@"name == 'Get milk'"]];
                [toDoRequest setFetchLimit:1];
                BBToDo *toDo = [[managedObjectContext executeFetchRequest:toDoRequest error:nil] lastObject];
                [toDo setList:list];
                
                [managedObjectContext save:nil];
            });
        });
    });
    
    context(@"With sections, offset and limit", ^{
        __block BBFetchedResultsController *controller;
        __block KWMock<BBFetchedResultsControllerDelegate> *delegate;
        beforeEach(^{
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBToDo entityName]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"completed == NO"]];
            NSSortDescriptor *byListName = [NSSortDescriptor sortDescriptorWithKey:@"list.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSSortDescriptor *byTaskName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [request setSortDescriptors:@[byListName, byTaskName]];
            [request setRelationshipKeyPathsForPrefetching:@[@"assignee"]];
            [request setFetchBatchSize:10];
            [request setFetchOffset:1];
            [request setFetchLimit:15];
            
            controller = [[BBFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"list.name"];
            delegate = [KWMock mockForProtocol:@protocol(BBFetchedResultsControllerDelegate)];
            [controller setDelegate:delegate];
            [[theValue([controller performFetch:nil]) should] beTrue];
        });
        
        it(@"should respect limit", ^{
            [[[controller should] have:15] fetchedObjects];
        });
        
        it(@"should group by section", ^{
            [[[controller sections] should] have:3];
            
            id<BBFetchedResultsSectionInfo> party = [[controller sections] objectAtIndex:0];
            [[[party name] should] equal:@"Party"];
            [[theValue([party numberOfObjects]) should] equal:theValue(2)];
            
            id<BBFetchedResultsSectionInfo> personal = [[controller sections] objectAtIndex:1];
            [[[personal name] should] equal:@"Personal"];
            [[theValue([personal numberOfObjects]) should] equal:theValue(11)];
            
            id<BBFetchedResultsSectionInfo> vacation = [[controller sections] objectAtIndex:2];
            [[[vacation name] should] equal:@"Vacation"];
            [[theValue([vacation numberOfObjects]) should] equal:theValue(2)];
        });

        it(@"should remove and insert sections when renaming section", ^{
            [[delegate should] receive:@selector(controllerWillChangeContent:) withArguments:controller, nil];
            [[delegate should] receive:@selector(controller:didChangeSection:atIndex:forChangeType:) withArguments:controller, any(), theValue(2), theValue(BBFetchedResultsChangeInsert), nil];
            [[delegate should] receive:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withArguments:controller, any(), [BBFetchedResultsIndexPath indexPathForRow:0 inSection:0], theValue(BBFetchedResultsChangeDelete), nil];
            [[delegate should] receive:@selector(controllerDidChangeContent:) withArguments:controller, nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[BBList entityName]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"name == 'Groceries'"]];
            [request setFetchLimit:1];
            BBList *list = [[managedObjectContext executeFetchRequest:request error:nil] lastObject];
            [list setName:@"Store"];
            [managedObjectContext save:nil];
        });
    });
    
    afterEach(^{
        NSError *error;
        BOOL succeeded = [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        [[theValue(succeeded) should] beTrue];
    });
});

SPEC_END
