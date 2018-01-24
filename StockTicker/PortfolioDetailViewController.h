//
//  PortfolioDetailViewController.h
//  StockTicker
//
//  Created by Florence Pagan on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StockPortfolio;

@interface PortfolioDetailViewController : UIViewController <UITextFieldDelegate>
{
    __weak IBOutlet UITextField *nameField;
}

@property (nonatomic, strong) StockPortfolio *portfolio;
@property (nonatomic) BOOL forAddition;
@property (nonatomic, copy) void (^refreshBlock)(void);

- (IBAction)backGroundTapped:(id)sender;


@end
