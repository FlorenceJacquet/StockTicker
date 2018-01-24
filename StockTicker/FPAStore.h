//
//  FPAStore.h
//  StockTicker
//
//  Created by Florence Pagan on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class StockPortfolio;


@interface FPAStore : NSObject
{
    NSMutableArray* allItems;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (FPAStore *) sharedStore;

- (StockPortfolio*) createPortfolio;
- (void) removePortfolio:(StockPortfolio*) portfolio;
- (void) movePortfolio:(int)from toIndex:(int)to;

- (StockPortfolio*) getPortfolioByName:(NSString*) name;

- (NSArray*) allPortfolios;

- (NSManagedObjectContext*) getContext;


// DB: get and save in DB
- (void) loadAll;
- (BOOL) saveChanges;


@end
