//
//  YahooHistData.h
//  StockTicker
//
//  Created by Florence Pagan on 12/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YahooHistData : NSObject
{
    
}

@property (nonatomic) int year;
@property (nonatomic) int month;
@property (nonatomic) int day;

@property (nonatomic) float price;


// Returns all stocks at close for everyday (array of YahooHistData).
// Tuple: 
// - NSDate*
// - float (value at close)
+ (NSArray*) getHistoricalData:(NSString *)symbol numYears:(int)numYears numMonths:(int)numMonths;

@end
