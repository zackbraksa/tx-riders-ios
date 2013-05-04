//
//  BIDMoreViewController.h
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDMoreViewController : UIViewController{
    UIActivityIndicatorView *activityIndicator;
}


@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *emailField;
@property (weak, nonatomic) IBOutlet UILabel *phoneField;
@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;

- (void) startAnimating;
- (void) stopAnimating;

- (IBAction)disconnectAction:(id)sender;
- (IBAction)goBackAction:(id)sender;

@end
