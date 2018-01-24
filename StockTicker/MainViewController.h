//
//  MainViewController.h
//  StockTicker
//
//  Created by Florence Pagan on 11/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSDate *dateLastRefreshed;
    NSMutableArray *arrHeaderViews;
    UIBarButtonItem *buttonRefreshLabel;
    
    UITableView *myTableView;
}

- (void) onSectionHeaderEditButtonClicked:(NSString *)portfolioName;


// Utils methods

// Return "Last refreshed on ..." string. UILabel used for display should allow 3 lines.
+ (void)displayLastRefreshed:(NSTimeInterval)interval lastWasSuccess:(BOOL)wasSuccess label:(UILabel*)label;

@end
