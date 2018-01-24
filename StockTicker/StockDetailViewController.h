//
//  StockDetailViewController.h
//  StockTicker
//
//  Created by Florence Pagan on 12/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StockItem;


@interface StockDetailViewController : UIViewController
{
    // Only for iPad
    UIView *chartView;
    UIViewController *chartController;
}

// GUI properties & methods

@property (weak, nonatomic) IBOutlet UILabel *symbol;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *priceChange;
@property (weak, nonatomic) IBOutlet UILabel *percentChange;
@property (weak, nonatomic) IBOutlet UILabel *dayRange;
@property (weak, nonatomic) IBOutlet UILabel *yearRange;
@property (weak, nonatomic) IBOutlet UILabel *divYield;
@property (weak, nonatomic) IBOutlet UILabel *lastRefreshLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


- (IBAction)chartTouchedUp:(id)sender;

- (IBAction)refreshTouchedDown:(id)sender;


// Passed as parameters

@property (nonatomic, weak) StockItem* item;
@property (nonatomic) NSTimeInterval lastRefreshed;
@property (nonatomic) BOOL wasLastRefreshSuccessful;

@end

