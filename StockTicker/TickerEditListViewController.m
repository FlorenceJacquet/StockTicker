//
//  TickerEditListViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 12/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TickerEditListViewController.h"
#import "StockPortfolio.h"
#import "StockItem.h"
#import "TickerDetailViewController.h"


@implementation TickerEditListViewController

@synthesize portfolio, refreshBlock;

- (id) init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        
        UIBarButtonItem *barAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
        [[self navigationItem]setRightBarButtonItem:barAdd];

        // Reshape bar "Back" button wth a "Done" button.
        UIBarButtonItem *barDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(popView:)];
        [[self navigationItem] setLeftBarButtonItem:barDone];
    }
    return self;
}

- (id) initWithStyle:(UITableViewStyle)style
{
    // Always use same style
    return [self init];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set title as portfolio name
    [[self navigationItem]setTitle:[portfolio name]];
    
    // This view is always in editing mode
    [self setEditing:YES];
}


/*- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}*/

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[portfolio allStockItems] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TickerEditList cellForRowAtIndexPath %d", [indexPath row]);
    // Check for reusable cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FPAStockDetailItemCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FPAStockDetailItemCell"];
    }
    
    NSString *tickerSymbol = [[[portfolio allStockItems] objectAtIndex:[indexPath row]] ticker];
    [[cell textLabel] setText:tickerSymbol];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If it is for a delete
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        StockItem *itemToDel = [[portfolio allStockItems] objectAtIndex:[indexPath row]];
        [portfolio removeStockItem:itemToDel];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [portfolio moveItem:[sourceIndexPath row] toIndex:[destinationIndexPath row]];
}


- (void) addClicked:(id)sender
{
    TickerDetailViewController *viewCtrl = [[TickerDetailViewController alloc] init];
    [viewCtrl setForAddition:YES];
    StockItem *newItem = [portfolio createStockItem];
    [viewCtrl setTicker:newItem];
    [viewCtrl setRefreshBlock:^(BOOL bOk)
     {
         if (bOk == NO)
             // User pressed cancel, we are not adding the ticker
             [[self portfolio] removeStockItem:newItem];
         [[self tableView] reloadData];
     }];
    
    // See also page 266, chapter 13.
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    [self presentViewController:navController animated:YES completion:nil];
    
    NSLog(@"Pushing view");
}

- (void) popView:(id)sender
{
    //[[self navigationController] popToRootViewControllerAnimated:YES];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:refreshBlock];
}


@end
