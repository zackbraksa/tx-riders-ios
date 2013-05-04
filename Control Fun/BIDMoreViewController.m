//
//  BIDMoreViewController.m
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import "BIDMoreViewController.h"
#import "BIDViewController.h"
#import <QuartzCore/QuartzCore.h>

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* user_profile = [defaults objectForKey:@"user_profile"];
    
    NSString* fullname = [[NSString alloc] initWithFormat:@"%@ %@",[user_profile objectForKey:@"nom"],[user_profile objectForKey:@"prenom"]];
    
    self.nameField.text = fullname;
    self.emailField.text = [user_profile objectForKey:@"email"];
    NSString *string = [user_profile objectForKey:@"telephone"];
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    self.phoneField.text = trimmedString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)disconnectAction:(id)sender {
    
    //get user_id from NSUserDefaults 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    //--
    
    //send a request to the server to remove this devide Push notification token from the db.
    [self.connection cancel];
    self.receivedData = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://test.braksa.com/tx/index.php/api/example/logout/format/json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    [request setHTTPMethod:@"POST"];
    NSString *postData = [[NSString alloc] initWithFormat:@"id=%@", user_id];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    [connection start];
    //--
    
    
    [self startAnimating];
    
        
}

- (IBAction)goBackAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [activityIndicator stopAnimating];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Erreur Connexion!"
                                                      message:@"Vérifier que vous êtes connecté"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK!"
                                            otherButtonTitles:nil];
    [message show];
    
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
        
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:self.receivedData
                          options:kNilOptions
                          error:nil];
    
    //NSLog(@"json: %@",json);
    
    
    if([[json objectForKey:@"status"] isEqualToString:@"done"])
    {
        //when logout action was done with succes (APN token removed) 
        [self stopAnimating];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        BIDViewController *loginView = [[BIDViewController alloc] initWithNibName:@"BIDViewController" bundle:nil];
        UIViewController *loginNavigationControllerView = [[UINavigationController alloc] initWithRootViewController:loginView];
                
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        window.rootViewController = loginNavigationControllerView;
        
    }else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Erreur!"
                                                          message:@"Vous n'êtes pas déconnecté."
                                                         delegate:nil
                                                cancelButtonTitle:@"Réessayez"
                                                otherButtonTitles:nil];
        [message show];
    }
}

- (void) startAnimating{
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.frame = self.view.bounds;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}
- (void) stopAnimating{
    [activityIndicator stopAnimating];
}

- (void)viewDidUnload {
    [self setNameField:nil];
    [self setEmailField:nil];
    [self setPhoneField:nil];
    [super viewDidUnload];
}
@end
