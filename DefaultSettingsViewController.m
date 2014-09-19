//
//  DefaultSettingsViewController.m
//  Tent
//
//  Created by Jeremy on 8/14/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "DefaultSettingsViewController.h"
#import "MyPFLogInViewController.h"
#import "MyPFSignUpViewController.h"
#import "MySchedulesTableViewController.h"


@interface DefaultSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation DefaultSettingsViewController


#pragma mark - View Controller Lifecycle

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        self.label.text = [NSString stringWithFormat:@"Currently logged in as %@.",currentUser.username];
    }
    else{ //No user logged in
        [self displayLoginAndSignUpViews];
    }
}

-(void)displayLoginAndSignUpViews
{
    // Create the log in view controller
    MyPFLogInViewController *logInViewController = [[MyPFLogInViewController alloc]init];
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten;

    [logInViewController setDelegate:self]; //set this class as the logInViewController's delegate
    
    // Create the sign up view controller
    MyPFSignUpViewController *signUpViewController = [[MyPFSignUpViewController alloc]init];
    signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;//can you do more than 1 additional?
    [signUpViewController setDelegate:self]; //set this class as the signUpViewController's delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    //present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];

}
#pragma mark - Log In View Controller Delegate
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}


// Sent to the delegate when a PFUser is logged in.
// (customize this later)
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
    [[[UIAlertView alloc] initWithTitle:@"Login unsuccessful"
                                message:@"Please re-enter your information"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    //maybe clear password
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Sign Up View Controller Delegate
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss the PFSignUpViewController
    
    
    
    
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (IBAction)logoutButton:(id)sender {
    [PFUser logOut];
    [self displayLoginAndSignUpViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 


@end
