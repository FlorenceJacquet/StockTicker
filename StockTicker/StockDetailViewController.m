//
//  StockDetailViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 12/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StockDetailViewController.h"
#import "StockItem.h"
#import "YahooWebServiceRequest.h"
#import "MainViewController.h"
#import "StockChartViewController.h"


@implementation StockDetailViewController

@synthesize item, lastRefreshed, wasLastRefreshSuccessful;

@synthesize symbol;
@synthesize price;
@synthesize priceChange;
@synthesize percentChange;
@synthesize dayRange;
@synthesize yearRange;
@synthesize divYield;
@synthesize lastRefreshLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [[self lastRefreshLabel] setNumberOfLines:3];
    [self displayStockInfo];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        // Load chart inside this view
        StockChartViewController *viewCtrl = [[StockChartViewController alloc] init];
        chartController = viewCtrl;
        [viewCtrl setItem:[self item]];
        chartView = [viewCtrl view];
        [chartView setFrame:CGRectMake(0, 400, 768, 720)];
        [[self view] addSubview:chartView]; 
    }
}

- (void)viewDidUnload
{
    [self setSymbol:nil];
    [self setPrice:nil];
    [self setPriceChange:nil];
    [self setPercentChange:nil];
    [self setDayRange:nil];
    [self setYearRange:nil];
    [self setDivYield:nil];
    [self setPrice:nil];
    [self setLastRefreshLabel:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    item = nil;
    
    chartView = nil;
    chartController = nil;
}

- (void) displayStockInfo
{
    [[self symbol] setText:[item ticker]];
    [[self nameLabel] setText:[item name]];
    [[self price] setText:[NSString stringWithFormat:@"%.2f", [item price]]];
    
    float num = [item priceChange];
    if (num >= 0)
    {
        [[self priceChange] setTextColor:[UIColor greenColor]];
        [[self priceChange] setText:[NSString stringWithFormat:@"+%.2f", [item priceChange]]];
        [[self percentChange] setTextColor:[UIColor greenColor]];
    }
    else 
    {
        [[self priceChange] setTextColor:[UIColor redColor]];
        [[self priceChange] setText:[NSString stringWithFormat:@"%.2f", [item priceChange]]];
        [[self percentChange] setTextColor:[UIColor redColor]];
    }
    [[self percentChange] setText:[item percentChange]];
    
    [[self dayRange] setText:[item dayRange]];
    [[self yearRange] setText:[item yearRange]];
    [[self divYield] setText:[item divYield]];
        
    [MainViewController displayLastRefreshed:[self lastRefreshed] lastWasSuccess:[self wasLastRefreshSuccessful] label:[self lastRefreshLabel]];
}
        
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)chartTouchedUp:(id)sender 
{
    // Launch stock chart screen
    StockChartViewController *viewCtrl = [[StockChartViewController alloc] init];
    [viewCtrl setItem:item];
    [[self navigationController] pushViewController:viewCtrl animated:YES];
}

- (IBAction)refreshTouchedDown:(id)sender 
{
    [YahooWebServiceRequest refreshQuote:item completionBlock:^(BOOL success){
        if (success == YES)
        {
            [self setLastRefreshed:[[NSDate date] timeIntervalSince1970]];
            [self setWasLastRefreshSuccessful:YES];
        }
        else 
        {
            [self setWasLastRefreshSuccessful:NO];
        }
        [self displayStockInfo];
    }];
}

@end
