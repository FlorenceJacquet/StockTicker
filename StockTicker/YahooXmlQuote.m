//
//  YahooXmlQuote.m
//  StockTicker
//
//  Created by Florence Pagan on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YahooXmlQuote.h"

@implementation YahooXmlQuote

@synthesize parentParserDelegate, symbol, priceChange, bidPrice, percentDayChange;
@synthesize dayRange, yearRange, divYield, lastTradePriceOnly, name;

- (id) init
{
    self = [super init];
    if (self)
    {
        bidPrice = nil;
        lastTradePriceOnly = nil;
    }
    return self;
}

//columns='Ask,AverageDailyVolume,Bid,AskRealtime,BidRealtime,BookValue,Change&PercentChange,Change,Commission,ChangeRealtime,AfterHoursChangeRealtime,DividendShare,LastTradeDate,TradeDate,EarningsShare,ErrorIndicationreturnedforsymbolchangedinvalid,EPSEstimateCurrentYear,EPSEstimateNextYear,EPSEstimateNextQuarter,DaysLow,DaysHigh,YearLow,YearHigh,HoldingsGainPercent,AnnualizedGain,HoldingsGain,HoldingsGainPercentRealtime,HoldingsGainRealtime,MoreInfo,OrderBookRealtime,MarketCapitalization,MarketCapRealtime,EBITDA,ChangeFromYearLow,PercentChangeFromYearLow,LastTradeRealtimeWithTime,ChangePercentRealtime,ChangeFromYearHigh,PercebtChangeFromYearHigh,LastTradeWithTime,LastTradePriceOnly,HighLimit,LowLimit,DaysRange,DaysRangeRealtime,FiftydayMovingAverage,TwoHundreddayMovingAverage,ChangeFromTwoHundreddayMovingAverage,PercentChangeFromTwoHundreddayMovingAverage,ChangeFromFiftydayMovingAverage,PercentChangeFromFiftydayMovingAverage,Name,Notes,Open,PreviousClose,PricePaid,ChangeinPercent,PriceSales,PriceBook,ExDividendDate,PERatio,DividendPayDate,PERatioRealtime,PEGRatio,PriceEPSEstimateCurrentYear,PriceEPSEstimateNextYear,Symbol,SharesOwned,ShortRatio,LastTradeTime,TickerTrend,OneyrTargetPrice,Volume,HoldingsValue,HoldingsValueRealtime,YearRange,DaysValueChange,DaysValueChangeRealtime,StockExchange,DividendYield'

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"el name %@", elementName);
    if ([elementName isEqualToString:@"BidRealtime"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setBidPrice:currentXmlString];
    }
    else if ([elementName isEqualToString:@"Change"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setPriceChange:currentXmlString];
    }
    else if ([elementName isEqualToString:@"PercentChange"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setPercentDayChange:currentXmlString];
    }
    else if ([elementName isEqualToString:@"DaysRange"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setDayRange:currentXmlString];
    }
    else if ([elementName isEqualToString:@"YearRange"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setYearRange:currentXmlString];
    }
    else if ([elementName isEqualToString:@"DividendYield"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setDivYield:currentXmlString];
    }
    else if ([elementName isEqualToString:@"LastTradePriceOnly"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setLastTradePriceOnly:currentXmlString];
    }
    else if ([elementName isEqualToString:@"Name"])
    {
        currentXmlString = [[NSMutableString alloc] init];
        [self setName:currentXmlString];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    [currentXmlString appendString:str];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"BidRealtime"]
        || [elementName isEqualToString:@"Change"]
        || [elementName isEqualToString:@"PercentChange"]
        || [elementName isEqualToString:@"DaysRange"]
        || [elementName isEqualToString:@"YearRange"]
        || [elementName isEqualToString:@"DividendYield"]
        || [elementName isEqualToString:@"LastTradePriceOnly"]
        || [elementName isEqualToString:@"Name"])
    {
        currentXmlString = nil;
    }
    else if ([elementName isEqualToString:@"quote"]) 
    {
        // We are done, give back hand to parent
        [parser setDelegate:parentParserDelegate];
    }
}

@end
