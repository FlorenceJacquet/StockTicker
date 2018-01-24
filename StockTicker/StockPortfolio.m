//
//  StockPortfolio.m
//  StockTicker
//
//  Created by Florence Pagan on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StockPortfolio.h"
#import "StockItem.h"
#import "FPAStore.h"

@interface StockPortfolio (CoreDataGeneratedAccessors)

 - (void)addItemsObject:(StockItem *)value;
 - (void)removeItemsObject:(StockItem *)value;
 - (void)addItems:(NSSet *)values;
 - (void)removeItems:(NSSet *)values;
 
@end


@implementation StockPortfolio

@dynamic name;
@dynamic lastRefreshed;
@dynamic items;
@dynamic indexInList;

@synthesize lastRefreshSucceeded;


- (StockItem *) createStockItem
{
    StockItem *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StockItem" inManagedObjectContext:[[FPAStore sharedStore] getContext]];
    [self addItemsObject:newItem];
    [newItem setIndexInList:[[self items] count] - 1];
    if (arrItems == nil)
    {
        // If we create the StockPortfolio on the fly (not fetched from DB)
        // we need to allocate iots array
        arrItems = [[NSMutableArray alloc] init];
    }
    [arrItems addObject:newItem];
    return  newItem;
}

- (void) removeStockItem:(StockItem *)item
{
    [self removeItemsObject:item];
    [[[FPAStore sharedStore] getContext] deleteObject:item];
    [arrItems removeObject:item];
    [self refreshIndexes];
}

- (void) removeStockItemByIndex:(int)index
{
    StockItem *item = [arrItems objectAtIndex:index];
    [self removeStockItem:item];
}

- (void) moveItem:(int)from toIndex:(int)to
{
    if (from == to)
        return;
    StockItem *pToMove = [arrItems objectAtIndex:from];
    [arrItems removeObjectAtIndex:from];
    [arrItems insertObject:pToMove atIndex:to];
    
    [self refreshIndexes];
}

- (NSArray *) allStockItems
{
    return arrItems;
}



// DB stuff

- (void) refreshIndexes
{
    int i;
    for (i = 0; i < [arrItems count]; i++)
    {
        StockItem *stockItem = [arrItems objectAtIndex:i];
        //NSLog(@"item name %@, index arrItems %d, index in DB %d", [stockItem ticker], i, [stockItem indexInList]);
        [stockItem setIndexInList:i];
    }
}

- (void) awakeFromFetch
{
    [super awakeFromFetch];
        
    int count = [[self items] count];
    arrItems = [[NSMutableArray alloc] initWithCapacity:count];
    
    // In our mutable array, we will put the items in the correct order
    NSArray *dbArray = [[self items] allObjects];    
    arrItems = [[NSMutableArray alloc] initWithArray:dbArray];

    [arrItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return ([obj1 indexInList] > [obj2 indexInList]);
    }];
    
    [self refreshIndexes];
    
    [self setLastRefreshSucceeded:YES];
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
}

@end
