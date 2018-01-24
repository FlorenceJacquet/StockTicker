//
//  YahooXmlQuote.h
//  StockTicker
//
//  Created by Florence Pagan on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YahooXmlQuote : NSObject <NSXMLParserDelegate>
{
    NSMutableString *currentXmlString;
}

@property (nonatomic, weak) id parentParserDelegate;

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSString *bidPrice;
@property (nonatomic, strong) NSString *priceChange;
@property (nonatomic, strong) NSString *percentDayChange;

@property (nonatomic, strong) NSString* dayRange;
@property (nonatomic, strong) NSString* yearRange;
@property (nonatomic, strong) NSString* divYield;
@property (nonatomic, strong) NSString* lastTradePriceOnly;
@property (nonatomic, strong) NSString* name;

@end
