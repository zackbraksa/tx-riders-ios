//
//  BIDSigninViewController.h
//  Control Fun
//
//  Created by Zakaria on 3/7/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDSigninViewController : UIViewController<UITextFieldDelegate>{
    UIActivityIndicatorView *activityIndicator;
    CGFloat animatedDistance;
}

@property (weak, nonatomic) IBOutlet UITextField *nomField;
@property (retain, nonatomic) NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UITextField *prenomField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UITextField *motdepasseField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) NSMutableData *receivedData;

- (IBAction)clickNext:(id)sender;
- (IBAction)goBackAction:(id)sender;

- (IBAction)textFieldDoneEditing:(id)sender;


@end
