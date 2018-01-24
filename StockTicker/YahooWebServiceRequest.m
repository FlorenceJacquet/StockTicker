//
//  YahooWebServiceRequest.m
//  StockTicker
//
//  Created by Florence Pagan on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YahooWebServiceRequest.h"
#import "StockPortfolio.h"
#import "StockItem.h"
#import "YahooXmlQuote.h"


@implementation YahooWebServiceRequest

- (id) init
{
    self = [super init];
    if (self)
    {
        xmlData = [[NSMutableData alloc] init];
        connection = nil;
        xmlQuoteList = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSMutableArray*) sharedReqList
{
    static NSMutableArray *list = nil;
    if (list == nil)
    {
        list = [[NSMutableArray alloc] init];
    }
    return list;
}

+ (void) refreshPortfolioQuotes:(StockPortfolio *)portfolio completionBlock:(void(^)(BOOL))block
{
    if ([[portfolio allStockItems] count] == 0)
        return;
    
    // YQL query: select * from yahoo.finance.quotes where symbol in ("YHOO","ABX","MSFT")
    NSMutableString *yqlQuery = [[NSMutableString alloc] initWithString:@"select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20("];
    int i;
    for (i = 0; i < [[portfolio allStockItems] count]; i++)
    {
        StockItem *item = [[portfolio allStockItems] objectAtIndex:i];        
        [yqlQuery appendString:@"%22"];
        [yqlQuery appendString:[item ticker]];
        [yqlQuery appendString:@"%22"];
        if (i != ([[portfolio allStockItems] count] - 1))
            [yqlQuery appendString:@"%2C"];
    }
    [yqlQuery appendString:@")"];
    
    NSMutableString *fullUrl = [[NSMutableString alloc] initWithString:@"https://query.yahooapis.com/v1/public/yql?q="];
    [fullUrl appendString:yqlQuery];
    [fullUrl appendString:@"&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"];
    
    NSLog(@"refreshPortfolioQuotes - URL: %@", fullUrl);
    
    YahooWebServiceRequest *yahooReq = [[YahooWebServiceRequest alloc] init];
    [yahooReq launchRequest:portfolio orOnlyQuote:nil url:fullUrl completionBlock:block];
    
    // Add object to static list of requests.
    [[YahooWebServiceRequest sharedReqList] addObject:yahooReq];
}

+ (void) refreshQuote:(StockItem *)item completionBlock:(void (^)(BOOL))block
{
    if (item == nil || [item ticker] == nil)
        return;
    
    // YQL query: select * from yahoo.finance.quotes where symbol in ("YHOO","ABX","MSFT")
    NSMutableString *yqlQuery = [[NSMutableString alloc] initWithString:@"select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22"];
    [yqlQuery appendString:[item ticker]];
    [yqlQuery appendString:@"%22)"];
    
    NSMutableString *fullUrl = [[NSMutableString alloc] initWithString:@"https://query.yahooapis.com/v1/public/yql?q="];
    [fullUrl appendString:yqlQuery];
    [fullUrl appendString:@"&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"];
    
    NSLog(@"refreshQuote - URL: %@", fullUrl);
    
    YahooWebServiceRequest *yahooReq = [[YahooWebServiceRequest alloc] init];
    [yahooReq launchRequest:nil orOnlyQuote:item url:fullUrl completionBlock:block];
    
    // Add object to static list of requests.
    [[YahooWebServiceRequest sharedReqList] addObject:yahooReq];
    
}

- (void) launchRequest:(StockPortfolio *)portfolioToGet orOnlyQuote:(StockItem*)quoteitem url:(NSString*)urlStr completionBlock:(void(^)(BOOL))block
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    portfolio = portfolioToGet;
    stock = quoteitem;
    completionBlock = block;
    
    // Create connection
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    // Show network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


// NSURLConnectionDataDelegate

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append data
    [xmlData appendData:data];
    NSLog(@"received data %d", [data length]);
    //NSLog(@"receive data %@", [NSString stringWithFormat:@"%@", data]);
}

- (void) connectionDidFinishLoading:(NSURLConnection *)conn
{
    //NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    //NSLog(@"Done %@", xmlCheck);
    
    // Hide network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Setup XML parsing
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];
}

- (void) connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    // Release connection object
    connection = nil;

    // Hide network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    // Remove oneself from list
    [[YahooWebServiceRequest sharedReqList] removeObject:self];
    
    NSLog(@"YahooWebServiceRequest failed with error: %@", [error localizedDescription]);
    [portfolio setLastRefreshSucceeded:NO];
    completionBlock(NO);
}


// NSXMLParserDelegate

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"quote"])
    {
        YahooXmlQuote *quoteEl = [[YahooXmlQuote alloc] init];
        [quoteEl setParentParserDelegate:self];

        // Get symbol name
        [quoteEl setSymbol:[attributeDict objectForKey:@"symbol"]];

        // Let the quote object parse its own XML
        [parser setDelegate:quoteEl];
        [xmlQuoteList addObject:quoteEl];
    }
    else {
        NSLog(@"error, element name is %@", elementName);
    }
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    int countQuote = [xmlQuoteList count];

    NSLog(@"parserDidEndDocument. Total quotes %d", countQuote);
    BOOL isSuccess = NO;
    if (countQuote > 0)
        isSuccess = YES;
    
    if (portfolio != nil)
    {
        // Map our stock tickers with the data retrieved
        for (StockItem *item in [portfolio allStockItems])
        {
            item.bOk = FALSE;
            for (YahooXmlQuote *quote in xmlQuoteList)
            {
                if ([[quote symbol] isEqualToString:[item ticker]])
                {
                    [self updateStockItem:item xmlQuote:quote];
                    break;
                }
            }
        }
        // Set refresh date
        if (isSuccess == YES)
        {
            [portfolio setLastRefreshed:[[NSDate date] timeIntervalSince1970]];
            [portfolio setLastRefreshSucceeded:YES];
        }
        else 
        {
            [portfolio setLastRefreshSucceeded:NO];
        }
    }
    else if (stock != nil)
    {
        for (YahooXmlQuote *quote in xmlQuoteList)
        {
            if ([[quote symbol] isEqualToString:[stock ticker]])
            {
                [self updateStockItem:stock xmlQuote:quote];
            }
        }       
    }
    
    // We are done!
    [[YahooWebServiceRequest sharedReqList] removeObject:self];
    
    completionBlock(isSuccess);
}

- (void) updateStockItem:(StockItem*)stockPtr xmlQuote:(YahooXmlQuote*)quote
{
    stockPtr.bOk = FALSE;
    
    if ([quote lastTradePriceOnly] != nil) {
        [stockPtr setPrice:[[quote lastTradePriceOnly] floatValue]];
        stockPtr.bOk = TRUE;
    }
    else if ([quote bidPrice] != nil) {
        [stockPtr setPrice:[[quote bidPrice] floatValue]];
    }
    [stockPtr setPriceChange:[[quote priceChange] floatValue]];
    [stockPtr setPercentChange:[quote percentDayChange]];  
    [stockPtr setDayRange:[quote dayRange]];
    [stockPtr setYearRange:[quote yearRange]];
    [stockPtr setDivYield:[quote divYield]];
    [stockPtr setName:[quote name]];
    
    // Case of mutual funds
    if ([stockPtr price] == 0)
        [stockPtr setPrice:[[quote lastTradePriceOnly] floatValue]];
}

@end
