//
//  SectionHeaderPortfolioView.h
//  StockTicker
//
//  Created by Florence Pagan on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionHeaderPortfolioView : UIView
{
    __weak IBOutlet UIButton *editButton;
    
    __weak IBOutlet UILabel *nameField;
}

// Action blocks
@property (nonatomic, copy) void (^buttonClickedBlock)(NSString *buttonType, NSString *portfolioName);

// Action event handlers
- (IBAction)onEditTouchUpInside:(id)sender;


- (void) setName:(NSString*)name;
- (NSString *) getName;


@end
