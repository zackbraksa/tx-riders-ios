

#import "BIDViewController.h"
#import "BIDHomeViewController.h"
#import "SSKeychain.h"
#import "BIDSigninViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface BIDViewController ()

@end

@implementation BIDViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)creerCompteAction:(id)sender {
    
    //if the user click the "create new account" button
    
    BIDSigninViewController *SignUpView = [[BIDSigninViewController alloc] initWithNibName:@"BIDSigninViewController" bundle:nil];
    [SignUpView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    //[SignUpView setModalTransitionStyle:UIModalTransitionStylePartialCurl]; //curl

    [self presentModalViewController:SignUpView animated:YES];
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}
- (IBAction)backgroundTap:(id)sender {
    [self.loginField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}


- (IBAction)loginPressed:(UIButton *)sender {
    
    NSLog(@"LOGIN");
    
    //load the apn token from the hard drive 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* apn = [defaults objectForKey:@"apnToken"];
    
    if(apn == NULL){
        NSLog(@"Couldn't find APN Token");
        NSString* apnString = @"<28b8d54c ac775b50 7d8a51c4 6424b1c1 2361cd15 3dfed444 2821d3e5 0a92ca77>";
        NSString* old_apn = [apnString stringByReplacingOccurrencesOfString:@" " withString:@""];
        apn = [old_apn substringWithRange:NSMakeRange(1, [old_apn length]-2)];
    }
    
    NSLog(@"My APN token is: %@", apn);
    
    
    //cancel if there is a connection 
    [self.connection cancel];
    
    self.receivedData = [[NSMutableData alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://test.braksa.com/tx/index.php/api/example/login/format/json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    [request setHTTPMethod:@"POST"];
    NSString *postData = [[NSString alloc] initWithFormat:@"email=%@&pwd=%@&apn=%@", [self.loginField text], [self.passwordField text], apn];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    //fire the connection and wait 
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
    
    //parse the reponse (json) 
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:self.receivedData
                          options:kNilOptions
                          error:nil];
    
    NSLog(@"json: %@",json);

    
    if([[json objectForKey:@"status"] isEqualToString:@"done"])
    {
        // the authentication was successful 
        
        //[SSKeychain setPassword:[self.passwordField text] forService:@"loginService" account:@"AnyUser"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[json objectForKey:@"user_id"] forKey:@"user_id"];
        
        //store the user profile somewhere
        [defaults setObject:[json objectForKey:@"profil"] forKey:@"user_profile"];
        
        //switch the home view 
        BIDHomeViewController* homeView = [[BIDHomeViewController alloc] initWithNibName:@"BIDHomeViewController" bundle:nil];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        window.rootViewController = homeView;
         
        
    }else{
        
        //the authentication wasn't successful then show error message 
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Erreur authentification!"
                                                          message:@"Mauvaise combinaison Login/Mot de Passe."
                                                         delegate:nil
                                                cancelButtonTitle:@"Réessayez"
                                                otherButtonTitles:nil];
        [message show];
    }
}


@end
