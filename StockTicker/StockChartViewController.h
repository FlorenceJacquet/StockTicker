//
//  StockChartViewController.h
//  StockTicker
//
//  Created by Florence Pagan on 12/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// References: 
// - http://www.readncode.com/blog/2012/05/15/ios-chart-and-plotting-library-comparison/
// - http://www.highcharts.com/documentation/how-to-use
// - https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
// We will try google charts.

@class StockItem;

@interface StockChartViewController : UIViewController
{
    __weak IBOutlet UISegmentedControl *periodSegCtrl;
    __weak IBOutlet UIWebView *webView;
    __weak IBOutlet UILabel *chartLabel;
    
    int numYears;
    int numMonths;
    NSArray *histData;
}

- (IBAction)onPeriodValueChanged:(id)sender;

@property (nonatomic, weak) StockItem* item;


@end
