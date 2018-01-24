//
//  StockChartViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 12/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StockChartViewController.h"
#import "StockItem.h"
#import "YahooHistData.h"

#define ERROR_HTML @"<html><body>Error</body></html>"

// 

#define TEST_HTML @"<html> \
    <head> \
    <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script> \
    <script type=\"text/javascript\"> \
        google.load(\"visualization\", \"1\", {packages:[\"corechart\"]}); \
        google.setOnLoadCallback(drawChart); \
        function drawChart() { \
            var options = { \
                title: '_SYMBOL_', \
                series: [{color: 'blue', visibleInLegend: false}], \
            }; \
            \
            var data = new google.visualization.DataTable(); \
            data.addColumn('date', 'Date'); \
            data.addColumn('number', 'Price'); \
            data.addRows([_DATA_]); \
            \
            var chart = new google.visualization.LineChart(document.getElementById('chart_div')); \
            chart.draw(data, options); \
        } \
    </script> \
    </head> \
    <body> \
    <div id=\"chart_div\" style=\"width: _WIDTH_px; height: _HEIGHT_px;\"></div> \
    </body> \
    </html>" 

@implementation StockChartViewController

@synthesize item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        
        [[self navigationItem] setTitle:@"Stock chart"];
        [chartLabel setText:@""];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    [periodSegCtrl setSelectedSegmentIndex:1];
    numYears = 1;
    numMonths = 0;
    histData = nil;
    
    // Prepair webView to look for some files in cache
    /*NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jsapi" ofType:@"js" inDirectory:@"www"]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];*/
    
    [self refreshHistData];
    [self displayHistData];
}

- (void)viewDidUnload
{
    periodSegCtrl = nil;
    webView = nil;
    histData = nil;
    chartLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onPeriodValueChanged:(id)sender 
{
    numMonths = 0;
    numYears = 0;
    switch([periodSegCtrl selectedSegmentIndex])
    {
        case 0:
            numMonths = 1;
            break;
        case 1:
            numYears = 1;
            break;
        case 2:
            numYears = 2;
            break;
        case 3:
            numYears = 5;
            break;
        case 4:
            numYears = 10;
            break;
        case 5:
            numYears = -1;
            break;
    }
    [self refreshHistData];
    [self displayHistData];
}

- (void) refreshHistData
{
    [chartLabel setText:@"Getting data..."];
    
    // Get data
    histData = [YahooHistData getHistoricalData:[item ticker] numYears:numYears numMonths:numMonths];    
}

- (void) displayHistData
{
    if (histData != nil)
    {
        NSMutableString *htmlStr = [[NSMutableString alloc] initWithString:TEST_HTML];
        
        // Replace "_SYMBOL_" by real value
        [htmlStr replaceOccurrencesOfString:@"_SYMBOL_" withString:[item ticker] options:NSCaseInsensitiveSearch range:NSMakeRange(0, 400)];
        
        // Replace string "_WIDTH_" with width
        NSInteger width = 320, height = 240;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            width = 700;
            height = 400;
        }
        [htmlStr replaceOccurrencesOfString:@"_WIDTH_" withString:[[NSString alloc] initWithFormat:@"%d", width] options:NSCaseInsensitiveSearch range:NSMakeRange(0, 900)];
        [htmlStr replaceOccurrencesOfString:@"_HEIGHT_" withString:[[NSString alloc] initWithFormat:@"%d", height] options:NSCaseInsensitiveSearch range:NSMakeRange(0, 900)];
        //NSLog(@"HTML: %@", htmlStr);        
        
        /* ['Year', 'Price', 'Expenses'], \
            ['2004',  1000,      400], \
            ['2005',  1170,      460], \
            ['2006',  660,       1120], \
            ['2007',  1030,      540] \
         
         new Date(2008, 10, 14)
         */       
         
        NSMutableString *dataStr = [[NSMutableString alloc] initWithString:@""];
        int y0, m0, d0, y1, m1, d1;
        
        for (int i = 0; i < [histData count]; i++)
        {
            YahooHistData *histItem = [histData objectAtIndex:i];
            if (i == 0)
            {
                y0 = [histItem year];
                m0 = [histItem month];
                d0 = [histItem day];
            }
            else if (i == [histData count] - 1)
            {
                y1 = [histItem year];
                m1 = [histItem month];
                d1 = [histItem day];
            }
            
            [dataStr appendFormat:@"[new Date(%d, %d, %d),  %02f] ", [histItem year], [histItem month], [histItem day], [histItem price]];
            if (i != [histData count]-1)
                [dataStr appendString:@", "];
        }
                
        // Replace string "_DATA_" with real stock data
        [htmlStr replaceOccurrencesOfString:@"_DATA_" withString:dataStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, 700)];
        
        //NSLog(@"HTML: %@", htmlStr);        
        NSLog(@"Display HTML and javascript data");

        [webView loadHTMLString:htmlStr baseURL:nil];
        
        // Chart info
        NSString *str = [[NSString alloc] initWithFormat:@"Chart from %d.%d.%d to %d.%d.%d", d0, m0, y0, d1, m1, y1];
        [chartLabel setText:str];
    }
    else 
    {
        [chartLabel setText:@"Error getting chart data"];
        //[webView loadHTMLString:ERROR_HTML baseURL:nil];
    }
}

@end
