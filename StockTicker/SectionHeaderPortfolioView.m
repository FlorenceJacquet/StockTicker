//
//  SectionHeaderPortfolioView.m
//  StockTicker
//
//  Created by Florence Pagan on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionHeaderPortfolioView.h"

@implementation SectionHeaderPortfolioView

@synthesize buttonClickedBlock;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"SectionHeaderPortfolioView" owner:self options:nil];
        [self addSubview:[xib objectAtIndex:0]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)onEditTouchUpInside:(id)sender 
{
    NSLog(@"Edit touch up %@", [nameField text]);

    [[NSOperationQueue mainQueue] addOperationWithBlock:^void(void){
        buttonClickedBlock(@"edit", [nameField text]);
    }];
}


- (void) setName:(NSString *)name
{
    nameField.text = name;
}

- (NSString *) getName
{
    return [nameField text];
}


@end
