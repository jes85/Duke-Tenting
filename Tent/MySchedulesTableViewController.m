//
//  MySchedulesTableViewController.m
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "MySchedulesTableViewController.h"
#import "MySchedulesTableViewCell.h"

#import "Constants.h"
#import "Schedule.h"
#import "HomeGame.h"
#import "Person.h"



#import "MyPFLogInViewController.h"
#import "MyPFSignUpViewController.h"

#import "MyScheduleContainerViewController.h"
#import "NewScheduleTableViewController.h"

@interface MySchedulesTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addScheduleButton;
@property PFUser *user;
@property (nonatomic) UIActivityIndicatorView *loadingWheel;

@property (nonatomic) NSMutableSet *mySchedulesHomeGameIndexes;

@end


@implementation MySchedulesTableViewController

-(NSMutableSet *)mySchedulesHomeGameIndexes
{
    if(!_mySchedulesHomeGameIndexes) _mySchedulesHomeGameIndexes = [[NSMutableSet alloc]init];
    return _mySchedulesHomeGameIndexes;
}

#pragma mark - View Controller Lifecycle

//TODO: Review the process of retreiving my schedules.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getHomeGamesDataFromUserDefaults];
    
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        self.loadingWheel.center = self.tableView.center;
        [self.loadingWheel startAnimating];
        [self getMySchedules];
        self.user = currentUser;
    }
    else{ //No user logged in
        //[self displayLoginAndSignUpViews];
    }
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Data"];
    [refresh addTarget:self action:@selector(refreshSchedules) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser){
        [self resetUserScheduleData];
        [self.tableView setNeedsDisplay];
        [self displayLoginAndSignUpViews];
    }else if(currentUser!=self.user){
        self.user = currentUser;
        [self.loadingWheel startAnimating];
        [self resetUserScheduleData];
        [self.tableView reloadData];
        [self getMySchedules];
        
    }
}

-(void)refreshSchedules
{
    [self getMySchedules];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];

}
-(void)stopRefresh
{
    [self.refreshControl endRefreshing];
}
-(void)resetUserScheduleData
{
    self.schedules = nil;
    self.mySchedulesHomeGameIndexes = nil;
}
//TODO: Review the process of retreiving home games.
-(void)getHomeGamesDataFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:kUserDefaultsHomeGamesData]; //testing
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

/*!
 *  Query Parse to retrieve schedules that current user is a part of
 */
-(void)getMySchedules
{
    PFRelation *relation = [[PFUser currentUser] relationForKey:kUserPropertyGroupSchedules];
    PFQuery *query = [relation query];
    [query orderByAscending:@"endDate"];
    [query includeKey:kGroupSchedulePropertyPersonsInGroup];
    [query includeKey:kGroupSchedulePropertyHomeGame];
    [query includeKey:kGroupSchedulePropertyCreatedBy];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", kGroupSchedulePropertyPersonsInGroup, kPersonPropertyAssociatedUser]];
    
  
    //[self.loadingWheel startAnimating];
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedulesForThisUser, NSError *error) {
        if(!error){
            self.schedules = nil; //TODO: in v2, compare retreived schedules to current and only update ones that have changed
            if([schedulesForThisUser count] == 0){
                //TODO: update view to say "You are not in any group schedules. Tap the plus button in the top right to create or join one".
                [self.loadingWheel stopAnimating];
                [self.tableView reloadData];
                return;
            }
            for(PFObject *parseSchedule in schedulesForThisUser){
                Schedule *scheduleObject = [MySchedulesTableViewController createScheduleObjectFromParseInfo:parseSchedule];
                [self addSchedule:scheduleObject];
            }
            [self.loadingWheel stopAnimating];
            [self.tableView reloadData];
        }
        else{
            [self.loadingWheel stopAnimating];
            NSLog(@"error retrieving user's schedules from parse");
            //TODO: update view to say "Error retrieving schedules"
        }
        
    }];
    

}

-(void)addSchedule:(Schedule *)schedule
{
    [self.schedules addObject:schedule];
    
    //TODO: only create this set on prepareforsegue. that way you don't have to update this set every time you update self.schedules
        // is creating this set on prepareForSEgue too slow?
    HomeGame *hg = schedule.homeGame;
    [self.mySchedulesHomeGameIndexes addObject:[NSNumber numberWithInteger:hg.index]];
}



+(Schedule *)createScheduleObjectFromParseInfo: (PFObject *)parseSchedule{
    
    NSString *groupName = parseSchedule[kGroupSchedulePropertyGroupName];
    NSString *groupCode = parseSchedule[kGroupSchedulePropertyGroupCode];
    NSDate *startDate = parseSchedule[kGroupSchedulePropertyStartDate];
    NSDate *endDate = parseSchedule[kGroupSchedulePropertyEndDate];
    BOOL assignmentsGenerated = [parseSchedule[kGroupSchedulePropertyAssignmentsGenerated] boolValue];
    NSString *parseObjectID = parseSchedule.objectId;
    
    PFObject *parseHomeGame = parseSchedule[kGroupSchedulePropertyHomeGame];
    NSString *opponent = parseHomeGame[kHomeGamePropertyOpponent];
    NSDate * gameTime = parseHomeGame[kHomeGamePropertyGameTime];
    BOOL isConferenceGame = parseHomeGame[kHomeGamePropertyConferenceGame];
    BOOL isExhibition = parseHomeGame[kHomeGamePropertyExhibition];
    NSUInteger index = [parseHomeGame[kHomeGamePropertyIndex] unsignedIntegerValue];
    HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition isConferenceGame:isConferenceGame index:index parseObjectID:parseHomeGame.objectId];
     
    PFObject *creator = parseSchedule[kGroupSchedulePropertyCreatedBy];
     
    NSArray *personsInGroup = parseSchedule[kGroupSchedulePropertyPersonsInGroup];
    NSMutableArray *personsArray = [[NSMutableArray alloc]initWithCapacity:personsInGroup.count];
    for(int i = 0; i < personsInGroup.count; i++){
        PFObject *parsePerson = (PFObject *)personsInGroup[i];
        //PFUser *user = parsePerson[kPersonPropertyAssociatedUser];
        PFObject *user = nil;
        NSString *offlineName = parsePerson[kPersonPropertyOfflineName];
        if(![parsePerson objectForKey: kPersonPropertyAssociatedUser]){
            offlineName = parsePerson[kPersonPropertyOfflineName];
        }else{
            user = parsePerson[kPersonPropertyAssociatedUser];
        }
        NSMutableArray *assignmentsArray = parsePerson[kPersonPropertyAssignmentsArray]; //TODO: do i need mutable copy?
        Person *person = [[Person alloc]initWithUser:user assignmentsArray:assignmentsArray scheduleIndex:i  parseObjectID:parsePerson.objectId];
        person.offlineName = offlineName;
        [personsArray addObject:person];
    }
    
    Schedule *schedule = [[Schedule alloc]initWithGroupName:groupName groupCode:groupCode startDate:startDate endDate:endDate intervalLengthInMinutes:60 personsArray:personsArray homeGame:homeGame createdBy:creator assignmentsGenerated:assignmentsGenerated parseObjectID:parseObjectID] ;
     
    return schedule;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if (self.schedules==nil | self.schedules.count == 0) {
        
        //TODO: display appropriate message
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
    return [self.schedules count]; //TODO: what if self.schedules = nil?
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MySchedulesTableViewCell *cell = (MySchedulesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"My Schedule Cell" forIndexPath:indexPath];
 
    // Configure the cell...
    Schedule *schedule = [self.schedules objectAtIndex:indexPath.row];
    HomeGame *homeGame = schedule.homeGame;
    cell.scheduleNameLabel.text = schedule.groupName;
    cell.opponentLabel.text = homeGame.opponentName;
    cell.gameTimeLabel.text = [[[Constants formatDate:homeGame.gameTime withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "] stringByAppendingString:[Constants formatTime:homeGame.gameTime withStyle:NSDateFormatterShortStyle]];
    
    if([schedule.startDate timeIntervalSinceNow] < 0){ //schedule has started
        if([homeGame.gameTime timeIntervalSinceNow] < 0 ){//game has happened
            cell.backgroundColor = [UIColor lightGrayColor];
            cell.startDateLabel.text = @"Game Over";
            cell.startDateLabel.textColor = [UIColor blueColor];
        }else{ //game is in progress
            cell.backgroundColor = [UIColor whiteColor];
            cell.startDateLabel.text = @"In Progress";
            cell.startDateLabel.textColor = [UIColor redColor];
        }
    }else { //schedule has not started yet
        
        NSDate *today;
        NSDate *startDay;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&today
                     interval:NULL forDate:[NSDate date]];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&startDay
                     interval:NULL forDate:schedule.startDate];

        NSDateComponents *components = [calendar components:(NSCalendarUnitDay) fromDate:today toDate:startDay options:0];
        cell.backgroundColor = [UIColor whiteColor];
        cell.startDateLabel.text = components.day == 0 ? @"Schedule Starts today" : [NSString stringWithFormat:@"Schedule Starts in %ld days", (long)components.day];

        cell.startDateLabel.textColor = [UIColor blackColor];
        
    }
 
    return cell;
}


#pragma mark - CallBacks

/*! Called when user chooses to join a schedule and enters the correct password.
 *  Adds user to the schedule, and saves to Parse
 */
-(IBAction)joinedSchedule:(UIStoryboardSegue *)segue
{
    
    PFQuery *query = [PFQuery queryWithClassName:kGroupScheduleClassName];
    //TODO: I could store actual scheduleParseObject in JoinScheduleViewController
    //TODO: Might need to deal with concurrency here
    //TODO: Maybe display loading wheel
    //TODO: deal with errors
    [query getObjectInBackgroundWithId: self.scheduleToJoin.parseObjectID block:^(PFObject *parseSchedule, NSError *error) {
        if(!error){
            NSLog(@"Retrieved schedule to join from parse");
            Person *newPerson = [[Person alloc]initWithUser:[PFUser currentUser] numIntervals:self.scheduleToJoin.numIntervals];
            PFObject *personObject = [PFObject objectWithClassName:kPersonClassName];
            personObject[kPersonPropertyAssignmentsArray] = newPerson.assignmentsArray;
            personObject[kPersonPropertyAssociatedUser] = newPerson.user;
            
    
            [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    NSLog(@"Saved new person object to parse");

                    NSMutableArray *personsArray = (NSMutableArray *)parseSchedule[kGroupSchedulePropertyPersonsInGroup]; //TODO: might need mutable copy
                    [personsArray addObject:personObject];
                    parseSchedule[kGroupSchedulePropertyPersonsInGroup] = (NSArray *)personsArray;
                    
                    [parseSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if(!error){
                         NSLog(@"Saved schedule to join to parse");

                         PFRelation *relation = [[PFUser currentUser] relationForKey:kUserPropertyGroupSchedules];
                         [relation addObject:parseSchedule];
                         [[PFUser currentUser] saveInBackground];
                         [self addSchedule:self.scheduleToJoin];
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
    
    
    //TODO: similar to join schedule todo's
    Schedule *newSchedule = self.scheduleToAdd;
    
    PFObject *scheduleObject = [PFObject objectWithClassName:kGroupScheduleClassName];
    scheduleObject[kGroupSchedulePropertyGroupName ] = newSchedule.groupName;
    scheduleObject[kGroupSchedulePropertyGroupCode] = newSchedule.groupCode;
    scheduleObject[kGroupSchedulePropertyStartDate] = newSchedule.startDate;
    scheduleObject[kGroupSchedulePropertyEndDate] = newSchedule.endDate;
    PFObject *homeGame = [PFObject objectWithoutDataWithClassName:kHomeGameClassName objectId:newSchedule.homeGame.parseObjectID];
    scheduleObject[kGroupSchedulePropertyHomeGame] = homeGame;
    scheduleObject[kGroupSchedulePropertyCreatedBy] = [PFUser currentUser];
    
    scheduleObject[kGroupSchedulePropertyAssignmentsGenerated] = [NSNumber numberWithBool:false];

    
    
   
    Person *person = [[Person alloc]initWithUser:[PFUser currentUser] numIntervals:self.scheduleToAdd.numIntervals];
    PFObject *personObject = [PFObject objectWithClassName:kPersonClassName];
    personObject[kPersonPropertyAssignmentsArray] = person.assignmentsArray;
    personObject[kPersonPropertyAssociatedUser] = person.user;
    personObject[kPersonPropertyIndex] = @0;
    
    /*
    [personObject saveInBackground];
    
    NSArray *personsArray = @[[PFObject objectWithoutDataWithClassName:kPersonClassName objectId:personObject.objectId]];
    scheduleObject[kGroupSchedulePropertyPersonsInGroup] = personsArray;
    
    [scheduleObject saveInBackground];
    
    PFRelation *userRelation = [[PFUser currentUser] relationForKey:kUserPropertyGroupSchedules];
    [userRelation addObject:[PFObject objectWithoutDataWithClassName:kGroupScheduleClassName objectId:scheduleObject.objectId]];
    [[PFUser currentUser] saveInBackground];
     */
    
    //TODO: do i need to do all of these separately or can I do them at the same time?check when objectID gets initialized
    [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            
            person.assignmentsArray = personObject[kPersonPropertyAssignmentsArray];
            person.parseObjectID = personObject.objectId;
            person.scheduleIndex = 0;
            NSMutableArray *personsArray = [[NSMutableArray alloc]initWithArray:@[person]];
            newSchedule.personsArray = personsArray;
            NSArray *parsePersonsArray = @[personObject];
            scheduleObject[kGroupSchedulePropertyPersonsInGroup] = parsePersonsArray;
            
            [scheduleObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    PFRelation *userRelation = [[PFUser currentUser] relationForKey:kUserPropertyGroupSchedules];
                    [userRelation addObject:scheduleObject];
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(!error){
                            [self addSchedule:newSchedule];
                            [self.tableView reloadData];

                        }
                    }];
                }
            }];
        }
    }];
    
     
}

-(IBAction)closeSettings:(UIStoryboardSegue *)segue
{
}
-(IBAction)scheduleDeleted:(UIStoryboardSegue *)segue
{
    [self refreshSchedules];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue destinationViewController] isKindOfClass:[MyScheduleContainerViewController class]]){
        if([sender isKindOfClass:[UITableViewCell class]]){
            MyScheduleContainerViewController *mscvc = [segue destinationViewController];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            if(indexPath){
                Schedule *schedule = self.schedules[indexPath.row];
                mscvc.schedule = schedule;
            }
        }
    }
    else if([[segue destinationViewController] isKindOfClass:[NewScheduleTableViewController class]]){
        if(sender==self.addScheduleButton){
            NewScheduleTableViewController *nstvc = [segue destinationViewController];
            //TODO: Possible changes heres
            nstvc.mySchedulesHomeGameIndexes = self.mySchedulesHomeGameIndexes;
            nstvc.homeGames = self.homeGames;
            nstvc.scrollRow = [self calculateScrollRowForNewSchedulesTVC];
            
            
            // Pointer testing
            self.test = @"hey";
            nstvc.test = self.test;
        }
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




@end
