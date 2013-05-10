//
//  BIDHomeViewController.h
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class BIDMapPoint;
@interface BIDHomeViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>{
    CLLocationManager *locationManager;
    UIActivityIndicatorView *activityIndicator;
    NSMutableArray* chauffeurs;
    BIDMapPoint* pinDepart;
}

- (void) fetchchauffeurs;
- (IBAction)fetchReservation;
- (IBAction)reserverAction:(id)sender;
- (IBAction)annulerReservationAction:(id)sender;
- (IBAction)refreshData:(id)sender; 
- (IBAction)bringConfigAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *boutonReserver;
@property (weak, nonatomic) IBOutlet UIButton *boutonAnnuler;
@property (weak, nonatomic) IBOutlet MKMapView *worldMap;
@property (retain, nonatomic) NSMutableData *chauffeursData;
@property (retain, nonatomic) NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UILabel *redTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *blackTitleLabel;

@property (retain, nonatomic) CLLocation *currentLocation;




@end
