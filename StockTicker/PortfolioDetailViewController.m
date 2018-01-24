//
//  PortfolioDetailViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PortfolioDetailViewController.h"
#import "StockPortfolio.h"
#import "FPAStore.h"
#import "TickerEditListViewController.h"


@implementation PortfolioDetailViewController

@synthesize portfolio, forAddition, refreshBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        forAddition = NO;
        
        // Custom initialization
        UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
        [[self navigationItem] setLeftBarButtonItem:buttonDone];
        UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked:)];
        [[self navigationItem] setRightBarButtonItem:buttonCancel];        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    if (portfolio != nil)
    {
        [nameField setText:[portfolio name]];
    }
}

- (void)viewDidUnload
{
    nameField = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    portfolio = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backGroundTapped:(id)sender 
{
    [[self view] endEditing:YES];
}


- (void) doneClicked:(id)sender
{
    if ([[nameField text] length] <= 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please set a name for portfolio" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Set portfolio name before exiting
    [portfolio setName:[nameField text]];
    
    //[[self navigationController] popToRootViewControllerAnimated:YES];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:refreshBlock];
}

- (void) cancelClicked:(id)sender
{
    if ([self forAddition] == YES)
    {
        // Remove portfolio
        [[FPAStore sharedStore] removePortfolio:portfolio];
    }
    
    //[[self navigationController] popToRootViewControllerAnimated:YES];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:refreshBlock];
}



@end
