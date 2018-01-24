//
//  SettingsViewController.m
//  StockTicker
//
//  Created by Florence Pagan on 12/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditPortfolioViewController.h"


@implementation SettingsViewController

@synthesize completionBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        UIBarButtonItem *barDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneClicked:)];
        [[self navigationItem] setLeftBarButtonItem:barDone];
        
        [[self navigationItem] setTitle:@"Settings"];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) doneClicked:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
    if (completionBlock != nil)
        completionBlock();
}

@end
