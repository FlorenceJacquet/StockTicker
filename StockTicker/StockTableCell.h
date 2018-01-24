//
//  StockTableCell.h
//  StockTicker
//
//  Created by Florence Pagan on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockTableCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *tickerName;
@property (weak, nonatomic) IBOutlet UILabel *tickerPrice;
@property (weak, nonatomic) IBOutlet UILabel *priceChange;
@property (weak, nonatomic) IBOutlet UILabel *changePercent;
@property (weak, nonatomic) IBOutlet UILabel *errorDisplay;


@end
