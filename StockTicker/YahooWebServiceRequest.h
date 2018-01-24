//
//  YahooWebServiceRequest.h
//  StockTicker
//
//  Created by Florence Pagan on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StockPortfolio, StockItem;

@interface YahooWebServiceRequest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSXMLParserDelegate>
{
    NSURLConnection *connection;
    NSMutableData *xmlData;
    NSMutableArray *xmlQuoteList;
    StockPortfolio *portfolio;
    StockItem *stock;
    
    void(^completionBlock)(BOOL);
}

+ (void) refreshPortfolioQuotes:(StockPortfolio*)portfolio completionBlock:(void(^)(BOOL))block;

+ (void) refreshQuote:(StockItem*)item completionBlock:(void(^)(BOOL))block;

@end
