//
//  BIDHomeViewController.m
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import "BIDHomeViewController.h"
#import "BIDReserverViewController.h"
#import "BIDMapPoint.h"
#import "BIDMoreViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface BIDHomeViewController ()

@end

@implementation BIDHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.worldMap.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.worldMap setShowsUserLocation:YES];
    
    
    //whenever the app enter foreground we need to refresh the current state of the map + reservation
    //so to do that we subscribe to UIApplicationDidBecomeActiveNotification using the Observer design pattern. 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = [defaults objectForKey:@"reservationStatus"];
    
    NSLog(@"Reservation status: %@",status);
    
    //if the reservation was accepted by a taxi driver then show a slightly different view
    if(status != NULL && [status isEqualToString:@"accepted"]){
        [self.boutonAnnuler setHidden:YES];
        self.redTitleLabel.text = @"Réservation acceptée";
        self.blackTitleLabel.text = @"Votre taxi est en route";
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    //try to find if there is any pending reservations
    [self fetchReservation];
    
    
    /*if([statut isEqualToString:@"pending"]){
        [self.boutonAnnuler setHidden:NO];
        [self.boutonReserver setHidden:YES];
        [self navigationController].navigationBar.topItem.title = @"Confirmation en cours";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary* dict = [defaults objectForKey:@"positionClient"];
        MKCoordinateRegion mapRegion;
        CLLocationCoordinate2D newCoord = { [[dict objectForKey:@"latitude"] floatValue], [[dict objectForKey:@"longitude"] floatValue] };
        mapRegion.center = newCoord;
        mapRegion.span.latitudeDelta = 0.0019;
        mapRegion.span.longitudeDelta = 0.0019;
        [self.worldMap setRegion:mapRegion animated: YES];
    }*/
    
}

- (IBAction)fetchReservation{
    
    NSLog(@"request: getReservation");
    
    NSMutableData *data = [[NSMutableData alloc] init];
    self.chauffeursData = data;
    [self.connection cancel];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    NSString* url_string = [[NSString alloc] initWithFormat:@"http://test.braksa.com/tx/index.php/api/example/reservation/id/%@/format/json", user_id ];
    
    NSURL *url = [NSURL URLWithString:url_string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    //start connection
    [connection start];
    
}

- (void) fetchchauffeurs{
    /* init connection  - request positions des chauffeurs */
    
    NSLog(@"request: getChauffeurs");
        
    NSMutableData *data = [[NSMutableData alloc] init];
    self.chauffeursData = data;
    [self.connection cancel];
    
    NSURL *url = [NSURL URLWithString:@"http://test.braksa.com/tx/index.php/api/example/chauffeurs/format/json"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    //start connection
    [connection start];
}





-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    
    NSDictionary* json = [NSJSONSerialization
                     JSONObjectWithData:self.chauffeursData
                     options:kNilOptions
                     error:nil];
    
    
    NSLog(@"%@",json);
    
    if([[json objectForKey:@"action"] isEqualToString:@"getReservation"]){
        
        NSLog(@"Reservations fetched from server: %@", [json objectForKey:@"status"]);

        if([[json objectForKey:@"status"] isEqualToString:@"done"]){
            
            //if the server send back that there is a reservation pending for the current user
            if([[[json objectForKey:@"reservation"] objectForKey:@"status"] isEqualToString:@"pending"]){
                
                // we need to hide le bouton reserver and show le bouton annuler
                [self.boutonAnnuler setHidden:NO]; 
                [self.boutonReserver setHidden:YES];
                //[self navigationController].navigationBar.topItem.title = @"Confirmation en cours";
                self.blackTitleLabel.text = @"Confirmation en cours";
                self.redTitleLabel.text = @"Vous allez recevoir une notification dans un moment.";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"pending" forKey:@"reservationStatus"];
                [defaults setObject:[[json objectForKey:@"reservation"] objectForKey:@"id"] forKey:@"reservation_id"];
                
                NSNumber* latitude = [[json objectForKey:@"reservation"] objectForKey:@"latitude"];
                NSNumber* longitude = [[json objectForKey:@"reservation"] objectForKey:@"longitude"];
                                
                MKCoordinateRegion mapRegion;
                CLLocationCoordinate2D newCoord = { [latitude floatValue], [longitude floatValue] };
                mapRegion.center = newCoord;
                mapRegion.span.latitudeDelta = 0.0019;
                mapRegion.span.longitudeDelta = 0.0019;
                BIDMapPoint *mp = [[BIDMapPoint alloc] initWithCoordinate:newCoord title:[NSString stringWithFormat:@"Adresse de départ"] subTitle:@"Adresse de départ"];
                pinDepart = mp;
                [self.worldMap addAnnotation:mp];
                [self.worldMap setRegion:mapRegion animated: YES];
                
            }else if([[[json objectForKey:@"reservation"] objectForKey:@"status"] isEqualToString:@"accepted"]){
                
                //if the server send back that the reservation was accepted by a taxi driver
                [self.boutonAnnuler setHidden:YES];
                [self.boutonReserver setHidden:YES];
                self.blackTitleLabel.text = @"Votre taxi est en route";
                self.redTitleLabel.text = @"Réservation acceptée";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"accepted" forKey:@"reservationStatus"];
                [defaults setObject:[[json objectForKey:@"reservation"] objectForKey:@"id"] forKey:@"reservation_id"];
                
                NSNumber* latitude = [[json objectForKey:@"reservation"] objectForKey:@"latitude"];
                NSNumber* longitude = [[json objectForKey:@"reservation"] objectForKey:@"longitude"];
                                
                MKCoordinateRegion mapRegion;
                CLLocationCoordinate2D newCoord = { [latitude floatValue], [longitude floatValue] };
                mapRegion.center = newCoord;
                mapRegion.span.latitudeDelta = 0.0019;
                mapRegion.span.longitudeDelta = 0.0019;
                BIDMapPoint *mp = [[BIDMapPoint alloc] initWithCoordinate:newCoord title:[NSString stringWithFormat:@"Adresse de départ"] subTitle:@"Adresse de départ"];
                pinDepart = mp;
                [self.worldMap addAnnotation:mp];
                [self.worldMap setRegion:mapRegion animated: YES];
                
            }
        }else{
            [self.boutonAnnuler setHidden:YES];
            [self.boutonReserver setHidden:NO];
            self.redTitleLabel.text = @"Bon à savoir";
            self.blackTitleLabel.text = @"Prenez un taxi en quelques minutes.";
            MKCoordinateRegion mapRegion;
            mapRegion.center = self.worldMap.userLocation.coordinate;
            mapRegion.span.latitudeDelta = 0.2;
            mapRegion.span.longitudeDelta = 0.2;
            if(pinDepart){
                [self.worldMap removeAnnotation:pinDepart];
            }
            [self.worldMap setRegion:mapRegion animated: YES];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"none" forKey:@"reservationStatus"];
            
            NSLog(@"No Reservation");
            
        }
        
        
        //try to fetch les chauffeurs 
        [self fetchchauffeurs];
        
    }else if([[json objectForKey:@"action"] isEqualToString:@"getChauffeurs"]){
        
        NSLog(@"chauffeurs fetched : %@", [json objectForKey:@"status"]);
        
        if([[json objectForKey:@"status"] isEqualToString:@"done"]){
            
            for(int i=0;i<[[json objectForKey:@"chauffeurs"] count]; i++){
                
                CGFloat latDelta = [[[[json objectForKey:@"chauffeurs"] objectAtIndex:i] objectForKey:@"latitude"] floatValue];
                CGFloat longDelta = [[[[json objectForKey:@"chauffeurs"] objectAtIndex:i] objectForKey:@"longitude"] floatValue];
                
                CLLocationCoordinate2D newCoord = { latDelta, longDelta };
                
                BIDMapPoint *mp = [[BIDMapPoint alloc] initWithCoordinate:newCoord title:[NSString stringWithFormat:@"Taxi"] subTitle:@"Adresse de départ"];
                
                [self.worldMap addAnnotation:mp];
            }
            
        }else{
            NSLog(@"Error getting chauffeurs.");
        }
        
    }else if([[json objectForKey:@"action"] isEqualToString:@"cancelReservation"]){
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"done" forKey:@"reservationStatus"];
        self.blackTitleLabel.text = @"Résérvation annulé";
        self.redTitleLabel.text = @"";
        
        [self.boutonReserver setHidden:NO];
        [self.boutonAnnuler setHidden:YES];
        
        [self.worldMap removeAnnotation:pinDepart];
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.worldMap.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.2;
        mapRegion.span.longitudeDelta = 0.2;
        
        [self.worldMap setRegion:mapRegion animated: YES];
        
    }else{
        
        NSLog(@"Error canceling reservation. %@", json);
    }
    
    
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.chauffeursData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@" , error);
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views{

    /*MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
    
    [mv setRegion:region animated:YES];*/
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *pinView = nil;
    if(annotation != self.worldMap.userLocation && ![[annotation title] isEqualToString:@"Adresse de départ"])
    {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKPinAnnotationView *)[self.worldMap dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKPinAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.canShowCallout = YES;
        pinView.image = [UIImage imageNamed:@"icon_taxi-y.gif"];
    }
    else {
        [self.worldMap.userLocation setTitle:@"Vous êtes ici"];
    }
    
    
    return pinView;
    
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reserverAction:(id)sender {
    UIViewController *reserverView = [[BIDReserverViewController alloc]
                                    initWithNibName:@"BIDReserverViewController"
                                    bundle:nil];
    
    [self presentModalViewController:reserverView animated:YES];
    
}




- (IBAction)bringConfigAction:(id)sender {
    BIDMoreViewController *configView = [[BIDMoreViewController alloc] initWithNibName:@"BIDMoreViewController" bundle:nil];
    [self presentModalViewController:configView animated:YES];
}

- (IBAction)refreshData:(id)sender {
    [self fetchReservation];
}

//prompt alertview when user want to cancel action
- (IBAction)annulerReservationAction:(id)sender {
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Annuler résérvation!"
                                                      message:@"Est ce que vous êtes sûre de bien vouloir annuler cette résérvation ?"
                                                     delegate:self
                                            cancelButtonTitle:@"Oui"
                                            otherButtonTitles:@"Non", nil];
    [message show];
}
//-- see next

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    // when the user click cancel, he get an alertview telling him to confirm his choice
    //this is where we check if he clicked Yes or No and based on that choice, either we cancel or not.
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Oui"])
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        self.chauffeursData = data;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *user_id = [defaults objectForKey:@"reservation_id"];
        
        NSString* url_string = [[NSString alloc] initWithFormat:@"http://test.braksa.com/tx/index.php/api/example/cancelReservation/id/%@/format/json", user_id ];
        
        NSURL *url = [NSURL URLWithString:url_string];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        self.connection = connection;
        
        //start connection
        [connection start];
    }
    else if([title isEqualToString:@"Non"])
    {
        //if user choose No, do nothing ! 
    }
    
}

- (void)viewDidUnload {
    [self setRedTitleLabel:nil];
    [self setBlackTitleLabel:nil];
    [super viewDidUnload];
}
@end
