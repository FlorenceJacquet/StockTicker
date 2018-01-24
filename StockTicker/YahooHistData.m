//
//  YahooHistData.m
//  StockTicker
//
//  Created by Florence Pagan on 12/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YahooHistData.h"

@implementation YahooHistData

@synthesize year, month, day, price;


+ (NSArray*) getHistoricalData:(NSString *)symbol numYears:(int)numYears numMonths:(int)numMonths
{
    int fromYear, fromMonth, toYear, toMonth, toDay;
    
    // Sample URL: http://ichart.finance.yahoo.com/table.csv?s=AAPL&c=1962
    NSMutableString *strUrl = [[NSMutableString alloc] init];
    [strUrl appendString:@"http://ichart.finance.yahoo.com/table.csv?s="];
    [strUrl appendString:symbol];
    
    // Now calculate year, month, day
    NSDate *now = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy"];
    toYear = [[df stringFromDate:now] intValue];
    [df setDateFormat:@"MM"];
    toMonth = [[df stringFromDate:now] intValue];
    [df setDateFormat:@"dd"];
    toDay = [[df stringFromDate:now] intValue];
    
    fromYear = toYear - numYears;
    if (numMonths == 0)
    {
        fromMonth = toMonth;
        if (fromMonth == 2 && toDay > 28)
            // Avoid issues with end of month...
            toDay = 28;
    }
    else 
    {
        fromMonth = toMonth - numMonths;
        if (fromMonth < 1)
        {
            fromMonth += 12;
            fromYear -= 1;
        }
        if (toDay > 28)
            // Avoid issues with end of month...
            toDay = 28;
    }
    
    // To date + weekly (g=w)
    [strUrl appendFormat:@"&d=%d&e=%02d&f=%d", toMonth - 1, toDay, toYear];
    if (numYears == -1 || numYears > 2)
    {
        [strUrl appendString:@"&g=m"];
    }
    else if (numMonths == 0) 
    {
        [strUrl appendString:@"&g=w"];
    }
    else 
    {
        [strUrl appendString:@"&g=d"];
    }
    
    // From date    
    if (numYears != -1)
    {
        [strUrl appendFormat:@"&a=%d&b=%02d&c=%d", fromMonth - 1, toDay, fromYear];
    }
    [strUrl appendString:@"&ignore=.csv"];
    
    NSLog(@"getHistoricalData %@", strUrl);
    
    /*
     http://stackoverflow.com/questions/754593/source-of-historical-stock-data
     
     sn = TICKER
     a = fromMonth-1
     b = fromDay (two digits)
     c = fromYear
     d = toMonth-1
     e = toDay (two digits)
     f = toYear
     g = d for day, m for month, y for yearly
     
     Example: http://ichart.finance.yahoo.com/table.csv?s=YHOO&d=0&e=28&f=2010&g=w&a=3&b=12&c=2008&ignore=.csv
    */

    NSURL *url = [NSURL URLWithString:strUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
        
    if (data != nil)
    {
        // Todo...
        NSLog(@"getHistoricalData %d", [data length]);
        
        // Parse .csv
        // Data sample: 
        //    Date,Open,High,Low,Close,Volume,Adj Close
        //    2012-10-15,21.08,21.54,21.01,21.47,4437300,21.47
        // We take the date and the value of stock at close
        
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *contentArray = [content componentsSeparatedByString:@"\n"];
        if ([contentArray count] > 1)
        {
            NSMutableArray *arr = [[NSMutableArray alloc] init];

            // Date format :"yyyy-MM-dd"
            int year, month, day;
            
            int i;  // ignore first item.
            for (i = 1; i < [contentArray count]; i++) 
            {
                NSString *item = [contentArray objectAtIndex:i];
                NSArray *itemArray = [item componentsSeparatedByString:@","];

                if ([itemArray count] >= 5)
                {
                    // Get date
                    //NSLog(@"%@",[itemArray objectAtIndex:0]);
                    NSString *date = [itemArray objectAtIndex:0];
                    NSString *tmp = [date substringWithRange:NSMakeRange(0, 4)];
                    year = [tmp intValue];
                    tmp = [date substringWithRange:NSMakeRange(5, 2)];
                    month = [tmp intValue];
                    tmp = [date substringWithRange:NSMakeRange(8, 2)];
                    day = [tmp intValue];
                
                    // Get stock at close
                    //NSLog(@"%@",[itemArray objectAtIndex:4]);
                    float stock = [[itemArray objectAtIndex:4] floatValue]; 
                
                    YahooHistData *histStock = [[YahooHistData alloc] init];
                    [histStock setYear:year];
                    [histStock setMonth:month];
                    [histStock setDay:day];
                    [histStock setPrice:stock];
                
                    [arr addObject:histStock];
                }
                else 
                    NSLog(@"empty line %d", i);
            }

            // Sort data
            NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                YahooHistData *item1 = (YahooHistData*)obj1;
                YahooHistData *item2 = (YahooHistData*)obj2;
                int tot1 = [item1 year] * 1000000 + [item1 month] * 1000 + [item1 day];
                int tot2 = [item2 year] * 1000000 + [item2 month] * 1000 + [item2 day];
                //return [first compare:second];
                return (tot1 > tot2);
            }];
            
            return sortedArray;
        }
        else
            NSLog(@"Error parsing csv data...");
    }
    else 
    {
        NSLog(@"Yahoo historical data: could not get data");
    }
    
    return nil;
}


@end
