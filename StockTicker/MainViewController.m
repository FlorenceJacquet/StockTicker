//
//  MainViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 11/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "TickerEditListViewController.h"
#import "StockPortfolio.h"
#import "StockItem.h"
#import "FPAStore.h"
#import "SectionHeaderPortfolioView.h"
#import "YahooWebServiceRequest.h"
#import "StockTableCell.h"
#import "StockDetailViewController.h"
#import "SettingsViewController.h"
#import "EditPortfolioViewController.h"

#define BAR_HEIGHT          44

@implementation MainViewController

- (id) init
{
    self = [super init];
    if (self)
    {
        
        UIBarButtonItem *barEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editClicked:)];
        [[self navigationItem]setLeftBarButtonItem:barEdit];
        [[self navigationItem]setTitle:@"Flo Portfolios"];
                
        arrHeaderViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithStyle:(UITableViewStyle)style
{
    // Always use same style
    return [self init];
}

// http://roadfiresoftware.com/2013/09/developing-for-ios-7-and-supporting-ios-6/. Does not work with simulator...
- (CGFloat)topOfViewOffset
{
    // For ios 7
    return 20; //self.topLayoutGuide.length;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isIpad = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        isIpad = YES;
    
    // Create spacer for toolbar (useful for iPad)
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (isIpad)
        [spacer setWidth:225];
    else 
        [spacer setWidth:1];
    
    // Toolbar stuff
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsClicked:)];
    UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshClicked:)];
    
    // Try to add a "Last refreshed on ..." label
    UILabel *labelRefresh = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, BAR_HEIGHT)];
    [labelRefresh setFont:[UIFont systemFontOfSize:11.0f]];
    [labelRefresh setBackgroundColor:[UIColor clearColor]];
    [labelRefresh setTextColor:[UIColor blackColor]];
    [labelRefresh setNumberOfLines:3];
    [labelRefresh setTextAlignment:NSTextAlignmentLeft];
    [labelRefresh setText:@"Last refreshed on ..."];
    buttonRefreshLabel = [[UIBarButtonItem alloc] initWithCustomView:labelRefresh];
    
    [toolbar setItems:[NSArray arrayWithObjects:button1, spacer, buttonRefreshLabel, spacer, button2, nil] animated:YES];
    CGRect frame = CGRectMake(0, [[self view] frame].size.height - BAR_HEIGHT, [[self view] frame].size.width, BAR_HEIGHT);
    [toolbar setFrame:frame];
    [[self view] addSubview:toolbar];
    
    // Add programmatically table view.
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [self topOfViewOffset] + BAR_HEIGHT, [[self view] frame].size.width, [[self view] frame].size.height - 2*BAR_HEIGHT - [self topOfViewOffset]) style:UITableViewStyleGrouped];
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    [[self view] addSubview:myTableView];

    // Custom cell
    // Load nib
    UINib *nib = [UINib nibWithNibName:@"StockTableCell" bundle:nil];
    // Register this nib for the cells
    [myTableView registerNib:nib forCellReuseIdentifier:@"FPAStockTableCell"];
    
    // Refresh data
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self refreshClicked:nil];
    }];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = [[FPAStore sharedStore] allPortfolios].count;
    //NSLog(@"numberOfSectionsInTableView %d", count);
    
    // Show last refreshed date
    if (count > 0)
    {
        StockPortfolio *portfolio0 = [[[FPAStore sharedStore] allPortfolios] objectAtIndex:0];
        NSTimeInterval interval = [portfolio0 lastRefreshed];
        UILabel *label = (UILabel*)[buttonRefreshLabel customView];
        
        [MainViewController displayLastRefreshed:interval lastWasSuccess:[portfolio0 lastRefreshSucceeded] label:label];
    }
    return [[FPAStore sharedStore] allPortfolios].count;
}



- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    StockPortfolio* item = [[[FPAStore sharedStore] allPortfolios] objectAtIndex:section];
    //NSLog(@"viewForHeaderInSection %d %@", section, [item name]);
    
    SectionHeaderPortfolioView *retView = nil;
    
    // Check if there is already a header view that was allocated
    if ([arrHeaderViews count] > section)
    {
        retView = [arrHeaderViews objectAtIndex:section];
        NSLog(@"Already in array");
        
        // Check if portfolio name has changed
        if (![[retView getName] isEqualToString:[item name]])
            [retView setName:[item name]];
    }
    else
    {
        // Load view for section header in table
        retView = [[SectionHeaderPortfolioView alloc] init];    
        [retView setName:[item name]];
        [arrHeaderViews addObject:retView];
        
        [retView setButtonClickedBlock:^void(NSString *typeButton, NSString *portfolioName){
            if ([typeButton isEqualToString:@"edit"])
                [self onSectionHeaderEditButtonClicked:portfolioName];
            else 
            {
                NSLog(@"button clicked in section header: unknown button");
            }
        }];
         
        NSLog(@"Added view to array");
    }
    return retView;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return 46;
    
    // Ipad
    return 60;
}

/*- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    StockPortfolio* item = [[[FPAStore sharedStore] allPortfolios] objectAtIndex:section];
    NSLog(@"titleForHeaderInSection %@", [item name]);
    return [item name];
}*/

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    StockPortfolio *portfolio = [[[FPAStore sharedStore] allPortfolios] objectAtIndex:section];
    //NSLog(@"numberOfRowsInSection %d", [[portfolio allStockItems] count]);
    return [[portfolio allStockItems] count];
}
                                  

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check for reusable cell
    StockTableCell *cell = (StockTableCell*)[myTableView dequeueReusableCellWithIdentifier:@"FPAStockTableCell"];
    
    // Todo...
    StockPortfolio *portfolio = [[[FPAStore sharedStore] allPortfolios] objectAtIndex:[indexPath section]];
    
    StockItem *item = [[portfolio allStockItems] objectAtIndex:[indexPath row]];
    
    [[cell tickerName] setText:[item ticker]];
    [[cell tickerPrice] setText:[NSString stringWithFormat:@"%.2f", [item price]]];
    
    NSString *text;

    // Set colors
    if ([item priceChange] > 0)
    {
        text = [NSString stringWithFormat:@"+%.2f", [item priceChange]];
        [[cell priceChange] setTextColor:[UIColor greenColor]];
        [[cell changePercent] setTextColor:[UIColor greenColor]];
    }
    else if ([item priceChange] == 0)
    {
        text = [NSString stringWithFormat:@"%.2f", [item priceChange]];
        [[cell priceChange] setTextColor:[UIColor blackColor]];
        [[cell changePercent] setTextColor:[UIColor blackColor]];
    }
    else // [item priceChange] < 0
    {
        text = [NSString stringWithFormat:@"%.2f", [item priceChange]];
        [[cell priceChange] setTextColor:[UIColor redColor]];
        [[cell changePercent] setTextColor:[UIColor redColor]];
    }

    // Set data
    [[cell priceChange] setText:text];
    [[cell changePercent] setText:[item percentChange]];
    
    // Set error status
    if (item.bOk == TRUE) {
        cell.errorDisplay.hidden = TRUE;
    }
    else {
        cell.errorDisplay.hidden = FALSE;
        [[cell errorDisplay] setTextColor:[UIColor purpleColor]];
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tapped cell section %d row %d", [indexPath section], [indexPath row]);
    
    StockPortfolio *portfolio = [[[FPAStore sharedStore] allPortfolios] objectAtIndex:[indexPath section]];
    StockItem *item = [[portfolio allStockItems] objectAtIndex:[indexPath row]];
    
    // Launch stock detailed view.
    StockDetailViewController *detailViewCtrl = [[StockDetailViewController alloc] init];
    [detailViewCtrl setItem:item];
    [detailViewCtrl setLastRefreshed:[portfolio lastRefreshed]];
    [detailViewCtrl setWasLastRefreshSuccessful:[portfolio lastRefreshSucceeded]];
    [[self navigationController] pushViewController:detailViewCtrl animated:YES];
    
    // Unselect row
    [myTableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Buttons stuff

- (void) settingsClicked:(id)sender
{
    SettingsViewController *settingsViewCtrl = [[SettingsViewController alloc] init];
    [settingsViewCtrl setCompletionBlock:^(void){
        [myTableView reloadData];
    }];
    [[self navigationController] pushViewController:settingsViewCtrl animated:YES];    
}

- (void) refreshClicked:(id)sender
{
    for (StockPortfolio *portfolio in [[FPAStore sharedStore] allPortfolios])
    {
        [YahooWebServiceRequest refreshPortfolioQuotes:portfolio completionBlock:^(BOOL success){
            [myTableView reloadData];
        }];
    }
}


- (void) editClicked:(id)sender
{
    EditPortfolioViewController *viewCtrl = [[EditPortfolioViewController alloc] init];
    [viewCtrl setRefreshBlock:^(void)
     {
         // If necessary, portfolio name already updated in view
         NSLog(@"reload data");
         [myTableView reloadData];
     }];
    [viewCtrl setDeletePortfolioBlock:^(NSString *portfolioName)
     {
         // User wants to delete the portfolio
         StockPortfolio *portfolio = [[FPAStore sharedStore] getPortfolioByName:portfolioName];
         if (portfolio)
         {
             int i;
             [[FPAStore sharedStore] removePortfolio:portfolio];
             // Remove portfolio section header
             for (i = 0; i < [arrHeaderViews count]; i++)
             {
                 if ([[[arrHeaderViews objectAtIndex:i] getName] isEqualToString:portfolioName])
                     [arrHeaderViews removeObjectAtIndex:i];
                 break;
             }
         }
         [myTableView reloadData];
     }];
    
    [[self navigationController] pushViewController:viewCtrl animated:YES];
    
    NSLog(@"Pushing edition view");    
}


// Methods used to handle buttons in section headers (portfolios)

- (void) onSectionHeaderEditButtonClicked:(NSString *)portfolioName
{
    NSLog(@"onSectionHeaderEditButtonClicked %@", portfolioName);
    TickerEditListViewController *viewCtrl = [[TickerEditListViewController alloc] init];
    StockPortfolio *portfolio = [[FPAStore sharedStore] getPortfolioByName:portfolioName];
    if (portfolio != nil)
    {
        [viewCtrl setPortfolio:portfolio];
        [viewCtrl setRefreshBlock:^(void)
         {
             // If necessary, portfolio name already updated in view
             NSLog(@"reload data");
             [myTableView reloadData];
         }];
    
        // See also page 266, chapter 13.
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        [self presentViewController:navController animated:YES completion:nil];
    
        NSLog(@"Pushing edition view");
    }
}

// Utils methods
+ (void)displayLastRefreshed:(NSTimeInterval)interval lastWasSuccess:(BOOL)wasSuccess label:(UILabel*)label
{
    NSString *str;
    [label setTextColor:[UIColor blackColor]];
    if (interval == 0)
    {
        // No data has ever been received from yahoo web service...
        str = @"To get data,\nclick on 'Refresh' button";
        [label setTextColor:[UIColor purpleColor]];
    }
    else
    {
        NSDate *dateRefreshed = [NSDate dateWithTimeIntervalSince1970:interval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
        str = @"Last refreshed on:\n";
        str = [str stringByAppendingString:[formatter stringFromDate:dateRefreshed]];
        if (wasSuccess == NO)
        {
            str = [str stringByAppendingString:@"\nLast refresh failed."];
            [label setTextColor:[UIColor purpleColor]];
        }
    }
    [label setText:str];
}

@end
