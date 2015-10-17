//
//  MySchedulesTableViewController.m
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "MySchedulesTableViewController.h"
#import "Schedule.h"
#import "CreateScheduleTableViewController.h"
#import "NameOfScheduleTableViewCell.h"
#import "MyScheduleContainerViewController.h"
#import "NewScheduleTableViewController.h"
#import "HomeGame.h"
#import "Constants.h"

#import "MyPFLogInViewController.h"
#import "MyPFSignUpViewController.h"


@interface MySchedulesTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addScheduleButton;
@property (nonatomic) NSMutableArray *publicSchedules;
@property PFUser *user;
@property (nonatomic) UIActivityIndicatorView *loadingWheel;

@end


@implementation MySchedulesTableViewController
#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getHomeGamesDataFromUserDefaults];
    
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        self.loadingWheel.center = self.tableView.center;
        [self.loadingWheel startAnimating];
        [self getMySchedules];
        UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = back;
        self.user = currentUser;
        

    }
    else{ //No user logged in
        //[self displayLoginAndSignUpViews];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser){
        self.schedules = nil;
        [self.tableView setNeedsDisplay];
        [self displayLoginAndSignUpViews];
    }else if(currentUser!=self.user){
        self.user = currentUser;
        [self.loadingWheel startAnimating];
        self.schedules = nil;
        [self.tableView reloadData];
        [self getMySchedules];
        
    }
}

-(void)getHomeGamesDataFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setObject:nil forKey:kUserDefaultsHomeGamesData]; //testing
    NSData *currentData = [userDefaults objectForKey:kUserDefaultsHomeGamesData];
    if(!currentData){
        [NewScheduleTableViewController loadHomeGameScheduleDataFromParseWithBlock:^(NSArray *updatedHomeGamesArray, NSError *error) {
            NSData *updatedData = [NSKeyedArchiver archivedDataWithRootObject:updatedHomeGamesArray];
            [userDefaults setObject:updatedData forKey:kUserDefaultsHomeGamesData];
            self.homeGames = updatedHomeGamesArray;
        }];
    }else{
        NSArray *currentHomeGameDataArray = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:currentData];
        self.homeGames = currentHomeGameDataArray;

    }
}

-(NSUInteger)calculateScrollRowForNewSchedulesTVC
{
    NSUInteger scrollRow = 0;
    HomeGame *lastGame = self.homeGames[self.homeGames.count-1];
    if([lastGame.gameTime timeIntervalSinceNow] < 0) return 0; //if all games have occurred, just show all of them
    for(int i=0;i<self.homeGames.count - 1;i++){ //don't need to check the last game twice
        HomeGame *game = self.homeGames[i];
        if([game.gameTime timeIntervalSinceNow] < 0){
            scrollRow = i+1;

        }
    }
    return scrollRow;
}

-(UIActivityIndicatorView *)loadingWheel
{
    if(!_loadingWheel){
        _loadingWheel = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingWheel.transform = CGAffineTransformMakeScale(1.75, 1.75);


    }
    return _loadingWheel;
}
#pragma mark - Login/Signup Control

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark - Properties - Lazy Instanstiation

-(NSMutableArray *)schedules{
    if(!_schedules)_schedules = [[NSMutableArray alloc]init];
    return _schedules;
}
-(NSMutableArray *)publicSchedules
{
    if(!_publicSchedules)_publicSchedules = [[NSMutableArray alloc]init];
    return _publicSchedules;
}




+(Schedule *)createScheduleObjectFromParseInfo: (PFObject *)parseSchedule{
        NSString *name = parseSchedule[kSchedulePropertyName];
        NSMutableArray *availabilitiesSchedule = parseSchedule[kSchedulePropertyAvailabilitiesSchedule];
        NSMutableArray *assignmentsSchedule = parseSchedule[kSchedulePropertyAssignmentsSchedule];
        NSDate *startDate = parseSchedule[kSchedulePropertyStartDate];
        NSDate *endDate = parseSchedule[kSchedulePropertyEndDate];
        NSUInteger numHourIntervals = [parseSchedule[kSchedulePropertyNumHourIntervals ] integerValue];
        NSString *privacy = parseSchedule[kSchedulePropertyPrivacy];
        NSString *password = parseSchedule[kSchedulePropertyPassword];
        NSUInteger homeGameIndex = [parseSchedule[kSchedulePropertyHomeGameIndex] integerValue];

    PFUser *creator = [parseSchedule objectForKey:@"creator"];
    
    
        NSString *objectID = parseSchedule.objectId;

        Schedule *scheduleObject = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex parseObjectID:objectID] ;
        
    
        return scheduleObject;
}

/*!
 *  Query Parse to retrieve schedules that current user is a part of
 */
-(void)getMySchedules
{
    PFRelation *relation = [[PFUser currentUser] relationForKey:kUserPropertySchedulesList];
    PFQuery *query = [relation query];
  
    //[self.loadingWheel startAnimating];
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedulesForThisUser, NSError *error) {
        self.schedules = nil;
        if(!error){
            for(PFObject *parseSchedule in schedulesForThisUser){
                Schedule *scheduleObject = [MySchedulesTableViewController createScheduleObjectFromParseInfo:parseSchedule];
                
                [self.schedules addObject:scheduleObject];
            }
            [self.loadingWheel stopAnimating];
            [self.tableView reloadData];
        }
        else{
            [self.loadingWheel stopAnimating];
            NSLog(@"error retrieving user's schedules from parse");
            //update view to say this
        }

        
    }];
    

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if (self.schedules==nil | self.schedules.count == 0) {
        if(self.loadingWheel.isAnimating){
            UILabel *messageLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                            self.tableView.bounds.size.width,
                                                                            self.tableView.bounds.size.height)];
            self.loadingWheel.center = messageLbl.center;
            [messageLbl addSubview:self.loadingWheel];
            self.tableView.backgroundView = messageLbl;
        }else{
            /*
            //create a lable size to fit the Table View
            UILabel *messageLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                            self.tableView.bounds.size.width,
                                                                            self.tableView.bounds.size.height)];
            //set the message
            messageLbl.text = @"Tap the + button in the top right to create or join a schedule. Your schedules will show up here.";
            //center the text
            messageLbl.textAlignment = NSTextAlignmentCenter;
            //auto size the text
            [messageLbl sizeToFit];
            
            //set back to label view
            self.tableView.backgroundView = messageLbl;
            //no separator
            
            */

        }
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }else{
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.schedules count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"My Schedule Cell" forIndexPath:indexPath];
 
    // Configure the cell...
    Schedule *schedule = [self.schedules objectAtIndex:indexPath.row];
    cell.textLabel.text = schedule.name;
     
 
    return cell;
}


#pragma mark - CallBacks

/*! Called when user chooses to join a schedule and enters the correct password.
 *  Adds user to the schedule, and saves to Parse
 */
-(IBAction)joinedSchedule:(UIStoryboardSegue *)segue
{
    
    PFQuery *query = [PFQuery queryWithClassName:kScheduleClassName];
    [query getObjectInBackgroundWithId: self.scheduleToJoin.parseObjectID block:^(PFObject *parseSchedule, NSError *error) {
        if(!error){
            
            Schedule *joinedScheduleObject = [MySchedulesTableViewController createScheduleObjectFromParseInfo:parseSchedule];
            /*
            NSString *name = parseSchedule[kSchedulePropertyName];
            NSMutableArray *availabilitiesSchedule = parseSchedule[kSchedulePropertyAvailabilitiesSchedule];
            NSMutableArray *assignmentsSchedule = parseSchedule[kSchedulePropertyAssignmentsSchedule];
            NSDate *startDate = parseSchedule[kSchedulePropertyStartDate];
            NSDate *endDate = parseSchedule[kSchedulePropertyEndDate];
            NSUInteger numHourIntervals = [parseSchedule[kSchedulePropertyNumHourIntervals ] integerValue];
            NSString *privacy = parseSchedule[kSchedulePropertyPrivacy];
            NSString *password = parseSchedule[kSchedulePropertyPassword];
            NSUInteger homeGameIndex = [parseSchedule[kSchedulePropertyHomeGameIndex] integerValue];
            */
            NSMutableArray *zeroesArray =[self createZeroesArrayOfLength: joinedScheduleObject.numHourIntervals];
            
            
            PFObject *personObject = [PFObject objectWithClassName:kPersonClassName];
            personObject[kPersonPropertyName] = [[PFUser currentUser] objectForKey:kUserPropertyFullName];
            personObject[kPersonPropertyIndex] = [NSNumber numberWithInteger:[joinedScheduleObject.availabilitiesSchedule count]];
            personObject[kPersonPropertyAvailabilitiesArray] = zeroesArray;
            personObject[kPersonPropertyAssignmentsArray] = zeroesArray;
            
            
            //[availabilitiesSchedule addObject:[zeroesArray copy]];
            //[assignmentsSchedule addObject:[zeroesArray copy]];
            [joinedScheduleObject.availabilitiesSchedule addObject:[zeroesArray copy]];
            [joinedScheduleObject.assignmentsSchedule addObject:[zeroesArray copy]];
            
            //parseSchedule[kSchedulePropertyAvailabilitiesSchedule] = availabilitiesSchedule;
            //parseSchedule[kSchedulePropertyAssignmentsSchedule] = assignmentsSchedule;
            
            parseSchedule[kSchedulePropertyAvailabilitiesSchedule] = joinedScheduleObject.availabilitiesSchedule;
            parseSchedule[kSchedulePropertyAssignmentsSchedule] = joinedScheduleObject.assignmentsSchedule;
            
            
            
            //Schedule *joinedSchedule = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex] ;

           
            personObject[@"scheduleName"] = joinedScheduleObject.name; //change this to a PFRelation to the schedule
            [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    PFRelation *relation = [parseSchedule relationForKey:kSchedulePropertyPersonsList];
                    [relation addObject:personObject];
                    
                   

                    [parseSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if(!error){
                         PFRelation *relation = [[PFUser currentUser] relationForKey:kUserPropertySchedulesList];
                         [relation addObject:parseSchedule];
                         [[PFUser currentUser] saveInBackground];
                         [self.schedules addObject:joinedScheduleObject];
                         [self.tableView reloadData];
                     }
                 }];
                }
            }];
        }
    }];
    
    
}

/*! 
 *  Called when user chooses to create a schedule.
 *  Creates the schedule, and saves to Parse
 */
-(IBAction)createSchedule:(UIStoryboardSegue *)segue
{
    //Schedule should implement copy protocol
    //Schedule *newSchedule = [self.scheduleToAdd copy];
    //[self.schedules addObject:newSchedule];
    //self.scheduleToAdd = nil;
    
    //Note: probably shouldn't update UI until after save success. b/c otherwise user will think they created the schedule, but it won't show up on other's phones
    
    
    
    Schedule *newSchedule = self.scheduleToAdd;
    [self.schedules addObject:newSchedule];
    
    [self.tableView reloadData];
    
    PFObject *scheduleObject = [PFObject objectWithClassName:kScheduleClassName];
    scheduleObject[kSchedulePropertyName ] = newSchedule.name;
    scheduleObject[kSchedulePropertyStartDate] = newSchedule.startDate;
    scheduleObject[kSchedulePropertyEndDate] = newSchedule.endDate;
   
    scheduleObject[kSchedulePropertyNumHourIntervals] = [NSNumber numberWithInteger:newSchedule.numHourIntervals];
    scheduleObject[kSchedulePropertyPrivacy] = newSchedule.privacy ? kPrivacyValuePrivate : kPrivacyValuePublic;
    scheduleObject[kSchedulePropertyPassword] = newSchedule.password;
    scheduleObject[kSchedulePropertyHomeGameIndex] = [NSNumber numberWithInteger:newSchedule.homeGameIndex];
    NSLog(@"index: %lu", (unsigned long)newSchedule.homeGameIndex);
    scheduleObject[kSchedulePropertyCreatedBy] = [PFUser currentUser];
   
    NSMutableArray *zeroesArray =[self createZeroesArrayOfLength: newSchedule.numHourIntervals];
    
    
    PFObject *personObject = [PFObject objectWithClassName:kPersonClassName];
    personObject[kPersonPropertyName] = [[PFUser currentUser] objectForKey:@"additional"];//change to first name
    personObject[kPersonPropertyIndex] = @0;
    personObject[kPersonPropertyAvailabilitiesArray] = zeroesArray;
    personObject[kPersonPropertyAssignmentsArray] = zeroesArray;
    personObject[@"scheduleName"] = newSchedule.name; //change this to a PFRelation to the schedule
    
    [newSchedule.availabilitiesSchedule addObject:[zeroesArray copy]];
    [newSchedule.assignmentsSchedule addObject:[zeroesArray copy]];
    
    scheduleObject[kSchedulePropertyAvailabilitiesSchedule] = newSchedule.availabilitiesSchedule;
    scheduleObject[kSchedulePropertyAssignmentsSchedule] = newSchedule.assignmentsSchedule;
    
    [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            PFRelation *scheduleRelation = [scheduleObject relationForKey:kSchedulePropertyPersonsList];
            [scheduleRelation addObject:personObject];
            [scheduleObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    PFRelation *userRelation = [[PFUser currentUser] relationForKey:kUserPropertySchedulesList];
                    [userRelation addObject:scheduleObject];
                    [[PFUser currentUser] saveInBackground];
                }
            }];
        }
    }];
     
}


/*!
 *  Create an array of zeroes of the specified length
 */
-(NSMutableArray *)createZeroesArrayOfLength: (NSUInteger)length
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:length];
    for(int i = 0; i<length; i++){
        [array addObject:@0];
    }
    return array;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    
    if([[segue destinationViewController] isKindOfClass:[MyScheduleContainerViewController class]]){
        MyScheduleContainerViewController *mscvc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            mscvc.schedule = self.schedules[indexPath.row];
        }
    }
    else if(sender==self.addScheduleButton){
        NewScheduleTableViewController *nstvc = [segue destinationViewController];
        nstvc.publicSchedules = self.publicSchedules;
        nstvc.mySchedules = self.schedules;
        nstvc.homeGames = self.homeGames;
        nstvc.scrollRow = [self calculateScrollRowForNewSchedulesTVC];
        
        self.test = @"hey";
        
        nstvc.test = self.test;
    }
}

-(IBAction)closeSettings:(UIStoryboardSegue *)segue
{
}


@end
