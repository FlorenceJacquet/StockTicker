//
//  StockTableCell.m
//  StockTicker
//
//  Created by Florence Pagan on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StockTableCell.h"

@implementation StockTableCell

@synthesize tickerName;
@synthesize tickerPrice;
@synthesize priceChange;
@synthesize changePercent;
@synthesize errorDisplay;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
