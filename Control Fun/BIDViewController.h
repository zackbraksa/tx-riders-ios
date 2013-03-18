//
//  BIDViewController.h
//  Login Controller
//

#import <UIKit/UIKit.h>
#import "BIDTabBarViewController.h"

@interface BIDViewController : UIViewController <UIActionSheetDelegate>{
    UIActivityIndicatorView *activityIndicator;
}

@property (retain, nonatomic) NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) NSMutableData *receivedData;


- (IBAction)creerCompteAction:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)loginPressed:(UIButton *)sender;

@end
