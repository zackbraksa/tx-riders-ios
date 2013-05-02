//
//  BIDReserverViewController.m
//  Control Fun
//
//  Created by Zakaria on 3/7/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import "BIDReserverViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface BIDReserverViewController ()

@end

@implementation BIDReserverViewController 

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
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)clickNext:(id)sender{
    
    NSLog(@"Next");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    //if there is a connection going on just cancel it.
    [self.connection cancel];
    
    //initialize new mutable data
    NSMutableData *data = [[NSMutableData alloc] init];
    self.receivedData = data;
    
    //initialize url that is going to be fetched.
    NSURL *url = [NSURL URLWithString:@"http://test.braksa.com/tx/index.php/api/example/reservation/format/json"];
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    
    //set http method
    [request setHTTPMethod:@"POST"];
    //initialize a post data
    NSString *postData = [[NSString alloc] initWithFormat:@"depart=%@&destination=%@&id=%@", [self.departField text],[self.destinationField text], user_id];
    
    //set request content type we MUST set this value.
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initialize a connection from request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    //start the connection
    [connection start];
    
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.frame = self.view.bounds;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
     
     
    
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
    
    
    [activityIndicator stopAnimating];
    
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:self.receivedData
                          options:kNilOptions
                          error:nil];
    
    
    
    if([[json objectForKey:@"status"] isEqualToString:@"done"])
    {
        NSLog(@"Reservation: %@",json);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"pending" forKey:@"reservationStatus"];
        [defaults setObject:[json objectForKey:@"depart"] forKey:@"positionClient"];
        
        
        NSLog(@"Reservation status: %@",[defaults objectForKey:@"reservationStatus"]);
        
        [self dismissModalViewControllerAnimated:YES];
        
    }else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Erreur Reservation!"
                                                          message:@"Votre adresse départ n'est pas valide."
                                                         delegate:nil
                                                cancelButtonTitle:@"Réessayez"
                                                otherButtonTitles:nil];
        [message show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldDoneEditing:(id)sender{
    NSLog(@"Resign");
    [self.departField resignFirstResponder];
}


- (IBAction)goBackAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)valueChanged:(UIStepper*)sender {
    if([sender tag] == 0){
        [self.passagersLabel setText:[[NSString alloc] initWithFormat:@"%0.f",[sender value]]];
    }else{
        [self.bagagesLabel setText:[[NSString alloc] initWithFormat:@"%0.f",[sender value]]];
    }
    
}
@end
