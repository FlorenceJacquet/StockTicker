//
//  ReorderPortfolioViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 12/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditPortfolioViewController.h"
#import "FPAStore.h"
#import "PortfolioDetailViewController.h"


@implementation EditPortfolioViewController


@synthesize myTablePortfolios, refreshBlock, deletePortfolioBlock;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        UIBarButtonItem *barDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
        [[self navigationItem] setLeftBarButtonItem:barDone];
        UIBarButtonItem *barAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
        [[self navigationItem] setRightBarButtonItem:barAdd];
        
        [[self navigationItem] setTitle:@"Edit portfolios"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [myTablePortfolios setDataSource:self];
    [myTablePortfolios setDelegate:self];
    [myTablePortfolios setEditing:YES];
    [myTablePortfolios setAllowsSelectionDuringEditing:YES];
}

- (void)viewDidUnload
{
    [self setMyTablePortfolios:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

/*
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Stop from showing delete button
    return  UITableViewCellEditingStyleDelete;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

// Table view stuff

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[FPAStore sharedStore] movePortfolio:[sourceIndexPath row] toIndex:[destinationIndexPath row]];
    [myTablePortfolios reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[FPAStore sharedStore] allPortfolios] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [myTablePortfolios dequeueReusableCellWithIdentifier:@"FPAPortfolioTableCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FPAPortfolioTableCell"];
    }
    
    [[cell textLabel] setText:[[[[FPAStore sharedStore] allPortfolios] objectAtIndex:[indexPath row]] name]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tapped cell section %d row %d", [indexPath section], [indexPath row]);
    
    StockPortfolio *portfolio = [[[FPAStore sharedStore] allPortfolios] objectAtIndex:[indexPath row]];
    
    // Launch stock detailed view.
    PortfolioDetailViewController *detailViewCtrl = [[PortfolioDetailViewController alloc] init];
    [detailViewCtrl setPortfolio:portfolio];
    [detailViewCtrl setForAddition:NO];
    [detailViewCtrl setRefreshBlock:^(void)
     {
         NSLog(@"reload data");
         [myTablePortfolios reloadData];
     }];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewCtrl];
    [self presentViewController:navController animated:YES completion:nil];
    
    // Unselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If it is for a delete
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *name = [[[[FPAStore sharedStore] allPortfolios] objectAtIndex:[indexPath row]] name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:name message:@"Do you really want to delete the portfolio?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"OK"])
        {
            // User wants to delete the portfolio
            deletePortfolioBlock([alertView title]);
                                 
            [myTablePortfolios reloadData];
        }
    }
}


- (void) doneClicked:(id)sender
{
    refreshBlock();
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) addClicked:(id)sender
{
    PortfolioDetailViewController *viewCtrl = [[PortfolioDetailViewController alloc] init];
    StockPortfolio *portfolio = [[FPAStore sharedStore] createPortfolio];
    [viewCtrl setPortfolio:portfolio];
    [viewCtrl setForAddition:YES];
    [viewCtrl setRefreshBlock:^(void)
     {
         NSLog(@"reload data");
         [myTablePortfolios reloadData];
     }];
    
    // See also page 266, chapter 13.
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    [self presentViewController:navController animated:YES completion:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
