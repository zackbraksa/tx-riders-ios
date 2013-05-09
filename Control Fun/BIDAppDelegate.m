//
//  BIDAppDelegate.m
//  App Delegate
//

#import "BIDAppDelegate.h"
#import "BIDViewController.h"
#import "BIDHomeViewController.h"
#import <Parse/Parse.h>


@implementation BIDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //[Parse setApplicationId:@"SZC8VUU9Sv5yu8GndXgV5U1u2EmtMf0zvXnQtuaP"
                  //clientKey:@"AhNGJl4iwsk6bw5J8IixQc94sDdGPKmO12UF8cmk"];
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                        UIRemoteNotificationTypeAlert|
                        UIRemoteNotificationTypeSound];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    NSLog(@"LOGIN user_id : %@",user_id);
    
    if(user_id == NULL){
        self.viewController = [[BIDViewController alloc] initWithNibName:@"BIDViewController" bundle:nil];
    }else{
        self.viewController = [[BIDHomeViewController alloc] initWithNibName:@"BIDHomeViewController" bundle:nil];
    }
    
    self.window.rootViewController = self.viewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)apnToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* apnString = [[NSString alloc] initWithData:apnToken encoding:NSUTF8StringEncoding];
    NSString* old_apn = [apnString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *apn = [old_apn substringWithRange:NSMakeRange(1, [old_apn length]-1)];
    NSLog(@"My token is: %@", apn);
    [defaults setObject:apn forKey:@"apnToken"];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //NSLog(@"userInfo %@",userInfo);
    //NSLog(@"aps %@",[userInfo objectForKey:@"aps"]);
    NSLog(@"alert %@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);

    NSLog(@"Got a new notification");
    
    NSString* msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:msg delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
    [message show];
    notif = true;
    
    //switch the app (views) to the mode when a taxi driver accepted the reservation
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"accepted" forKey:@"reservationStatus"];

}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] == 3010) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
