//
//  TickerEditListViewController.h
//  StockTicker
//
//  Created by Florence Pagan on 12/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StockPortfolio;

@interface TickerEditListViewController : UITableViewController
{
    
}

@property (nonatomic, strong) StockPortfolio *portfolio;

@property (nonatomic, copy) void (^refreshBlock)(void);

@end
