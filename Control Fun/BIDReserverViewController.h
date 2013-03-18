//
//  BIDReserverViewController.h
//  Control Fun
//
//  Created by Zakaria on 3/7/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDReserverViewController : UIViewController <UITextFieldDelegate>{
    UIActivityIndicatorView *activityIndicator;
}


@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;


- (IBAction)valueChanged:(UIStepper*)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (void)clickNext;




@property (weak, nonatomic) IBOutlet UILabel *bagagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *passagersLabel;
@property (weak, nonatomic) IBOutlet UIStepper *bagagesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *passagersStepper;
@property (weak, nonatomic) IBOutlet UITextField *departField;
@property (weak, nonatomic) IBOutlet UITextField *destinationField;



@end