//
//  TickerDetailViewController.h
//  StockTicker
//
//  Created by Florence Pagan on 12/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StockItem;

@interface TickerDetailViewController : UIViewController <UITextFieldDelegate>
{
    __weak IBOutlet UITextField *tickerName;
}

- (IBAction)backgroundTapped:(id)sender;

@property (nonatomic) BOOL forAddition;
@property (nonatomic, copy) void (^refreshBlock)(BOOL bOk);

@property (nonatomic, strong) StockItem* ticker;

@end
