//
//  StockItem.h
//  StockTicker
//
//  Created by Florence Pagan on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StockItem : NSManagedObject

// See page 323.

// DB stuff
@property (nonatomic, retain) NSString * ticker;
@property (nonatomic) float price;
@property (nonatomic) float priceChange;
@property (nonatomic, retain) NSString *percentChange;
@property (nonatomic) int32_t indexInList;
@property (nonatomic, retain) NSManagedObject *portfolio;


// Stuff not saved in DB
@property (nonatomic, strong) NSString *dayRange;
@property (nonatomic, strong) NSString *yearRange;
@property (nonatomic, strong) NSString *divYield;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL bOk;


@end
