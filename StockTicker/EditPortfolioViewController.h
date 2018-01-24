//
//  ReorderPortfolioViewController.h
//  StockTicker
//
//  Created by Florence Pagan on 12/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPortfolioViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UITableView *myTablePortfolios;


@property (nonatomic, copy) void (^refreshBlock)(void);
@property (nonatomic, copy) void (^deletePortfolioBlock)(NSString *portfolioName);

@end
