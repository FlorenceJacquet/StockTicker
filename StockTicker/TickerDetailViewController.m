//
//  TickerDetailViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 12/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TickerDetailViewController.h"
#import "StockItem.h"


@implementation TickerDetailViewController

@synthesize ticker, forAddition, refreshBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        forAddition = NO;
        
        // Custom initialization
        UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
        UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
        
        [[self navigationItem]setLeftBarButtonItem:buttonDone];
        [[self navigationItem] setRightBarButtonItem:buttonCancel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    tickerName = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (IBAction)backgroundTapped:(id)sender 
{
    [[self view] endEditing:YES];
}

- (void) doneClicked:(id)sender
{
    if ([[tickerName text] length] <= 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error, no symbol" message:@"Please set a symbol for ticker" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    //[[self navigationController] popToRootViewControllerAnimated:YES];
    [ticker setTicker:[[tickerName text] uppercaseString]];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    // Call completion block given to us by the view calling us
    [[NSOperationQueue mainQueue] addOperationWithBlock:^void(void){
        refreshBlock(YES);
    }];

}

- (void) cancelClicked:(id)sender
{   
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];

    // Call completion block given to us by the view calling us
    [[NSOperationQueue mainQueue] addOperationWithBlock:^void(void){
        refreshBlock(NO);
    }];
}


@end
