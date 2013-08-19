# BBFetchedResultsController

### _Like NSFetchedResultsController, but better._

Apple’s NSFetchedResultsController is great, but has some shortcomings:

- Changes to relationship objects affecting the order or predicate (i.e. addition or removal) aren’t detected.
- The fetch limit isn’t respected after updates.
- Reports conflicting section/object updates when objects move to newly-created sections or move from newly deleted-sections.
- Implicit object moves are unnecessarily reported (e.g. deleting one object and changing the ordinal on all subsequent objects turn up as a single row deletion and multiple moves as opposed to updates).
- Changes to relationship objects specified in relationshipKeypathsForPrefetching aren’t detected.
- Changing the sort descriptors and/or predicate and then performing a fetch doesn’t result in delegate calls.
- Not Mac compatible.

BBFetchedResultsController solves all of these problems.

## Features

### Detects Changes to Relationships Affecting Order and Inclusion

If a relationship key path is used in a sort descriptor or predicate and then that value changes, that change will be detected and the delegate will be notified accordingly.

### Respects Fetch Limit

Even after the managed object context is saved, the fetch request limit is respected. For example, if you set the fetch request’s limit to 5, perform the fetch, add a few more managed objects and save the context, your delegate will get callbacks that still correspond to that fetch limit.

### Object Moves Don’t Conflict With Section Changes

Delegate callbacks don’t conflict with UITableView’s fine-grained insertion, deletion and move calls. That is, if an object is moved from a newly-deleted section, the delegate will be told that the section has been deleted and the object has been inserted at the new location (as opposed to a section deletion and an object move), and that will keep UITableView happy / prevent it from breaking. Likewise, if an object is moved to a newly-inserted section, the delegate will be told that the section has been inserted and the object has been deleted at the previous location.

### Ignores Implicit Object Moves

Only actual, explicit object moves are interpreted as moves. For example, if an object is moved from the first position in a section to the last and the other objects in the section also happen to be updated, the delegate will be notified that there was one move and the others will count as updates (as opposed to all being reported as moves).

### Reports Changes from Updating Sort Descriptors and Predicate

After making changes to the fetch request’s sort descriptors or predicate, calling `performFetch:` will detect how the sections and objects have been affected and report those changes to the delegate.

### Detects Changes to Prefetched Relationships

BBFetchedResultsController observes changes to relationship objects specified in relationshipKeyPathsForPrefetching and does so only for objects that haven’t been faulted so that no unnecessary faulting occurs. For example, if you’re displaying the first ten to-dos in a table and each to-do cell displays the associated to-do list’s name, well then you’d want prefetch the list relationship with relationshipKeyPathsForPrefetching and set your fetch request’s batch size to say, ten. When a list’s name changes for one of those ten, faulted to-dos, that will be detected as an update and your delegate will be notified so that you can easily keep your UI in sync with the data.

### Mac Compatible

Go ahead, fire it up on a Mac.

## Installation

1. [Download the files](https://github.com/benrblakely/BBFetchedResultsController/archive/master.zip).
2. Copy the `BBFetchedResultsController` folder into your project’s directory.
3. Drag the files into Xcode.
4. Add `#import "BBFetchedResultsController.h"` to your project’s prefix header, e.g. `MyApp-Prefix.pch`.
5. Enjoy!
