//
//  BIDViewController.h
//  Login Controller
//

#import <UIKit/UIKit.h>

@interface BIDViewController : UIViewController <UIActionSheetDelegate>{
    UIActivityIndicatorView *activityIndicator;
}

@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;
@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;



- (IBAction)creerCompteAction:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)loginPressed:(UIButton *)sender;

@end
