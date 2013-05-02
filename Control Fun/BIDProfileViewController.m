//
//  BIDProfileViewController.m
//  Control Fun
//
//  Created by Zakaria on 3/21/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import "BIDProfileViewController.h"

@interface BIDProfileViewController ()

@end

@implementation BIDProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* user_profile = [defaults objectForKey:@"user_profile"];
    
    NSString* fullname = [[NSString alloc] initWithFormat:@"%@ %@",[user_profile objectForKey:@"nom"],[user_profile objectForKey:@"prenom"]];
    
    self.nomField.text = fullname;
    self.emailField.text = [user_profile objectForKey:@"email"];
    self.telField.text = [user_profile objectForKey:@"telephone"];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBackAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setNomField:nil];
    [self setEmailField:nil];
    [self setTelField:nil];
    [super viewDidUnload];
}
@end
