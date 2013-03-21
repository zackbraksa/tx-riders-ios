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
#import <QuartzCore/QuartzCore.h>


@interface BIDHomeViewController ()

@end

@implementation BIDHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                   target:self
                                   action:@selector(fetchReservation)];
        self.navigationItem.rightBarButtonItem = button;

        /* change tab item title */
        
        UITabBarItem* tbi = [self tabBarItem];
        [tbi setTitle:@"Carte"];
        UIImage* i = [UIImage imageNamed:@"globe.png"];
        [tbi setImage:i];
    
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.worldMap.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.worldMap setShowsUserLocation:YES];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *statut = [defaults objectForKey:@"status_reservation"];
    
    NSLog(@"status reservation: %@",statut);
    
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
    
    [self fetchReservation];
    
    [super viewWillAppear:animated];
}

- (void) fetchchauffeurs{
    /* init connection  - request positions chauffeurs */
    
    NSLog(@"req sent: getChauffeurs");
        
    NSMutableData *data = [[NSMutableData alloc] init];
    self.chauffeursData = data;
    
    NSURL *url = [NSURL URLWithString:@"http://test.braksa.com/tx/index.php/api/example/chauffeurs/format/json"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    //start connection
    [connection start];
}


- (void) fetchReservation{
    
    
    NSLog(@"req sent: getReservation");
    
    NSMutableData *data = [[NSMutableData alloc] init];
    self.chauffeursData = data;
    
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


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    
    NSDictionary* json = [NSJSONSerialization
                     JSONObjectWithData:self.chauffeursData
                     options:kNilOptions
                     error:nil];
    
    if([[json objectForKey:@"action"] isEqualToString:@"getReservation"]){
        
        NSLog(@"Reservation fetched : %@", [json objectForKey:@"status"]);

        if([[json objectForKey:@"status"] isEqualToString:@"done"]){
            if([[[json objectForKey:@"reservation"] objectForKey:@"status"] isEqualToString:@"pending"]){
                [self.boutonAnnuler setHidden:NO];
                [self.boutonReserver setHidden:YES];
                [self navigationController].navigationBar.topItem.title = @"Confirmation en cours";
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[[json objectForKey:@"reservation"] objectForKey:@"id"] forKey:@"reservation_id"];
                
                NSNumber* latitude = [[json objectForKey:@"reservation"] objectForKey:@"latitude"];
                NSNumber* longitude = [[json objectForKey:@"reservation"] objectForKey:@"longitude"];
                
                NSLog(@"");
                
                MKCoordinateRegion mapRegion;
                CLLocationCoordinate2D newCoord = { [latitude floatValue], [longitude floatValue] };
                mapRegion.center = newCoord;
                mapRegion.span.latitudeDelta = 0.0019;
                mapRegion.span.longitudeDelta = 0.0019;
                BIDMapPoint *mp = [[BIDMapPoint alloc] initWithCoordinate:newCoord title:[NSString stringWithFormat:@"Adresse de départ"] subTitle:@"Adresse de départ"];
                pinDepart = mp;
                [self.worldMap addAnnotation:mp];
                [self.worldMap setRegion:mapRegion animated: YES];
                
            }else{
                
            }
        }else{
            [self.boutonAnnuler setHidden:YES];
            [self.boutonReserver setHidden:NO];
            [self navigationController].navigationBar.topItem.title = @"Carte des taxis";
            MKCoordinateRegion mapRegion;
            mapRegion.center = self.worldMap.userLocation.coordinate;
            mapRegion.span.latitudeDelta = 0.2;
            mapRegion.span.longitudeDelta = 0.2;
            if(pinDepart){
                [self.worldMap removeAnnotation:pinDepart];
            }
            [self.worldMap setRegion:mapRegion animated: YES];
            
            
        }
        
        [self fetchchauffeurs];
        
    }
    else if([[json objectForKey:@"action"] isEqualToString:@"getChauffeurs"]){
        
        NSLog(@"chauffeurs fetched : %@", [json objectForKey:@"status"]);
        if([[json objectForKey:@"status"] isEqualToString:@"done"]){
            for(int i=0;i<[[json objectForKey:@"chauffeurs"] count]; i++){
                
                CGFloat latDelta = [[[[json objectForKey:@"chauffeurs"] objectAtIndex:i] objectForKey:@"latitude"] floatValue];
                CGFloat longDelta = [[[[json objectForKey:@"chauffeurs"] objectAtIndex:i] objectForKey:@"longitude"] floatValue];
                
                CLLocationCoordinate2D newCoord = { latDelta, longDelta };
                
                BIDMapPoint *mp = [[BIDMapPoint alloc] initWithCoordinate:newCoord title:[NSString stringWithFormat:@"Taxi"] subTitle:@"Adresse de départ"];
                
                [self.worldMap addAnnotation:mp];
            }
        }
        else{
            NSLog(@"Error getting chauffeurs.");
        }
    }
    else if([[json objectForKey:@"action"] isEqualToString:@"cancelReservation"]){
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"statut_reservation"];
        [self navigationController].navigationBar.topItem.title = @"Résérvation annulé";
        
        [self.boutonReserver setHidden:NO];
        [self.boutonAnnuler setHidden:YES];
        
        [self.worldMap removeAnnotation:pinDepart];
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.worldMap.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.2;
        mapRegion.span.longitudeDelta = 0.2;
        
        [self.worldMap setRegion:mapRegion animated: YES];
        
    }else{
        NSLog(@"Creepy error. %@", json);
    }
    
    
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.chauffeursData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@" , error);
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{

    /*MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
    
    [mv setRegion:region animated:YES];*/
}

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //CLLocationCoordinate2D userCoordinate = userLocation.location.coordinate;
    
    /*
    CGFloat latDelta = 49.8626696;
    CGFloat longDelta = 2.3349731 ;
    CLLocationCoordinate2D newCoord = { latDelta, longDelta };
    BIDMapPoint *mp = [[BIDMapPoint alloc] initWithCoordinate:newCoord title:[NSString stringWithFormat:@"Taxi"] subTitle:@"Adresse de départ"];
    [self.worldMap addAnnotation:mp];*/

    
}



- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
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
        [self.worldMap.userLocation setTitle:@"I am here"];
    }
    
    
    return pinView;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reserverAction:(id)sender {
    UIViewController *secondView = [[BIDReserverViewController alloc]
                                    initWithNibName:@"BIDReserverViewController"
                                    bundle:nil];
    
    [[self navigationController] pushViewController:secondView animated:YES];
}

- (IBAction)annulerReservationAction:(id)sender {
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Annuler résérvation!"
                                                      message:@"Est ce que vous êtes sûre de bien vouloir annuler cette résérvation ?"
                                                     delegate:self
                                            cancelButtonTitle:@"Oui"
                                            otherButtonTitles:@"Non", nil];
    [message show];
    
    
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
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
        
    }
    
}

@end
