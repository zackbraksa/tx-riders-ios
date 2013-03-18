//
//  BIDTabBarViewController.m
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import "BIDTabBarViewController.h"
#import "BIDHomeViewController.h"
#import "BIDFavoritesViewController.h"
#import "BIDMoreViewController.h"

@interface BIDTabBarViewController ()

@end

@implementation BIDTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        BIDHomeViewController *firstView = [[BIDHomeViewController alloc] initWithNibName:@"BIDHomeViewController" bundle:nil];
        
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:firstView];
        
        navController.navigationBar.tintColor = [UIColor blackColor];
        navController.navigationBar.topItem.title = @"Carte";
        
        BIDFavoritesViewController *secondView = [[BIDFavoritesViewController alloc] initWithNibName:@"BIDFavoritesViewController" bundle:nil];
        BIDMoreViewController *thirdView = [[BIDMoreViewController alloc] initWithNibName:@"BIDMoreViewController" bundle:nil];
        
        NSArray *viewControllersArray = [[NSArray alloc] initWithObjects:navController, secondView,thirdView, nil];
        
        
        [self setViewControllers:viewControllersArray];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
