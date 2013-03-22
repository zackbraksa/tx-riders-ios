//
//  BIDMoreViewController.m
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import "BIDMoreViewController.h"
#import "BIDViewController.h"

@interface BIDMoreViewController ()

@end

@implementation BIDMoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem* tbi = [self tabBarItem];
        [tbi setTitle:@"Paramétres"];
        UIImage* i = [UIImage imageNamed:@"cog.png"];
        [tbi setImage:i];
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

- (IBAction)disconnectAction:(id)sender {
    //[SSKeychain deletePasswordForService:@"loginService" account:@"AnyUser"];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    BIDViewController *loginView = [[BIDViewController alloc] initWithNibName:@"BIDViewController" bundle:nil];
    UIViewController *loginNavigationControllerView = [[UINavigationController alloc] initWithRootViewController:loginView];
    
    //((UINavigationController*)loginNavigationControllerView).navigationBar.tintColor = [UIColor blackColor];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = loginNavigationControllerView;
        
}

- (IBAction)goBackAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
