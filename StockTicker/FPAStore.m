//
//  FPAStore.m
//  StockTicker
//
//  Created by Florence Pagan on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FPAStore.h"
#import "StockPortfolio.h"

@implementation FPAStore

static FPAStore *sharedStore = nil;

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (FPAStore*) sharedStore
{
    // Add mutual exclusion
    @synchronized([FPAStore class])
    {    
        if (!sharedStore)
        {
            sharedStore = [[super allocWithZone:nil] init];
        }
    }
    return sharedStore;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        //allItems = [[NSMutableArray alloc] init];
        
        // Read in model
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Where does the SQLite file go?
        NSString *path = [self itemStoragePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *err = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&err])
        {
            [NSException raise:@"Open DB failed" format:@"Reason: %@", [err localizedDescription]];
        }
        
        // Create managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
        
        [self loadAll];
    }
    return self;
}

- (StockPortfolio*) createPortfolio
{
    StockPortfolio *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StockPortfolio" inManagedObjectContext:context];
    [newItem setIndexInList:[allItems count]];
    [newItem setLastRefreshSucceeded:YES];
    [allItems addObject:newItem];
    return newItem;
}

- (StockPortfolio *) getPortfolioByName:(NSString *)name
{
    int i;
    for (i = 0; i < [allItems count]; i++)
    {
        if ([[[allItems objectAtIndex:i] name] isEqualToString:name])
            return [allItems objectAtIndex:i];
    }
    return nil;
}

- (void) removePortfolio:(StockPortfolio *)portfolio
{
    if (portfolio == nil)
    {
        NSLog(@"ERROR, trying to remove nil portfolio");
        return;
    }
    [allItems removeObject:portfolio];
    
    // TODO: does it remove and delete the items???
    [context deleteObject:portfolio];
    
    [self refreshIndexes];
}

- (void) movePortfolio:(int)from toIndex:(int)to
{
    if (from == to)
        return;
    StockPortfolio *pToMove = [allItems objectAtIndex:from];
    [allItems removeObjectAtIndex:from];
    [allItems insertObject:pToMove atIndex:to];
    
    [self refreshIndexes];
}

- (NSArray *) allPortfolios
{
    return allItems;
}


- (NSManagedObjectContext*) getContext
{
    return context;
}


// DB stuff

- (void) refreshIndexes
{
    int i;

    for (i = 0; i < [allItems count]; i++)
    {
        StockPortfolio *portfolio = [allItems objectAtIndex:i];
        [portfolio setIndexInList:i];
    }
}

- (void) loadAll
{
    if (!allItems)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *eP = [[model entitiesByName] objectForKey:@"StockPortfolio"];
        [request setEntity:eP];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"indexInList" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *err = nil;
        
        NSArray *results = [context executeFetchRequest:request error:&err];
        if (!results)
        {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [err localizedDescription]];
        }
        allItems = [[NSMutableArray alloc] initWithArray:results];
        
        // Set correctly the indexes
        [self refreshIndexes];
    }
}

- (BOOL) saveChanges
{
    NSError *err = nil;
    BOOL success = [context save:&err];
    if (!success)
    {
        NSLog(@"Error saving %@", [err localizedDescription]);
    }
    return success;
}

- (NSString *) itemStoragePath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dir0 = [docDirs objectAtIndex:0];
    return [dir0 stringByAppendingPathComponent:@"fpastoreFloTicker.data"];
}

@end
