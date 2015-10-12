//
//  JoinScheduleTableViewController.m
//  Tent
//
//  Created by Jeremy on 8/31/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "JoinScheduleTableViewController.h"
#import "Schedule.h"
#import <Parse/Parse.h>
#import "ScheduleTableViewCell.h"
#import "MySchedulesTableViewController.h"
#import "Constants.h"


#define kEnterPasswordAlertViewTitle            @"Enter Password: "
#define kCancelButtonTitle                      @"Cancel"
#define kEnterButtonTitle                       @"Enter"

#define kWrongPasswordAlertViewTitle            @"Password Incorrect!"
#define kWrongPasswordAlertViewMessage          @"Please enter the password again."

@interface JoinScheduleTableViewController ()

@property (nonatomic) Schedule *scheduleToJoin;
@end

@implementation JoinScheduleTableViewController

#pragma mark - View Controller Lifecycle
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getSchedulesAssociatedWithHomeGameIndex];
    
    
}

/*!
 * Query Parse to get all the schedules that have been created for the selected home game
 */
-(void)getSchedulesAssociatedWithHomeGameIndex
{
    
    PFQuery *query = [PFQuery queryWithClassName:kScheduleClassName];
    [query whereKey:kSchedulePropertyHomeGameIndex equalTo:[NSNumber numberWithInteger:self.homeGameIndex ]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedules, NSError *error) {
        if(!schedules){
            NSLog(@"Find failed");
        }else if ([schedules count]<1){
            NSLog(@"No schedules associated with home game index %lu in Parse", (unsigned long)self.homeGameIndex);
        }else{
            NSLog(@"Find schedules associated with home game index %lu succeeded", (unsigned long)self.homeGameIndex);
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for(PFObject *parseSchedule in schedules){
                
                Schedule *scheduleObject = [MySchedulesTableViewController createScheduleObjectFromParseInfo:parseSchedule] ;
                
                [array addObject:scheduleObject];
            }
            
            self.schedulesAssociatedWithThisHomeGame = [array sortedArrayUsingDescriptors:[self getSortDescriptors]];
            [self.tableView reloadData];
            
        }
    }];
    
    
}

-(NSArray *)getSortDescriptors
{
    NSArray *sortDescriptors;
    NSSortDescriptor *sortByScheduleName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];;
    NSSortDescriptor *sortByCreatorName = [NSSortDescriptor sortDescriptorWithKey:@"creator" ascending:YES];
;
    NSSortDescriptor *sortByStartDate = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];;


    switch (self.filterBy) {
        case 0: //schedule name
            sortDescriptors = @[sortByScheduleName, sortByStartDate, sortByCreatorName];
            
            break;
        case 1: //creator name
            sortDescriptors = @[sortByCreatorName, sortByStartDate, sortByScheduleName];
            break;
        case 2: //start date
            sortDescriptors = @[sortByStartDate, sortByScheduleName, sortByCreatorName];
            break;
            
        default:
            sortDescriptors = @[sortByScheduleName, sortByStartDate, sortByCreatorName];
            break;
    }
    return sortDescriptors;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.schedulesAssociatedWithThisHomeGame count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinScheduleCell" forIndexPath:indexPath];
    
    Schedule *schedule = self.schedulesAssociatedWithThisHomeGame[indexPath.row];
    
    // Configure the cell...
    cell.nameLabel.text = schedule.name;
    cell.startDate.text = [[[Constants formatDate:schedule.startDate withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "]stringByAppendingString:[Constants formatTime:schedule.startDate withStyle:NSDateFormatterShortStyle]];
     cell.endDate.text = [[[Constants formatDate:schedule.endDate withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "]stringByAppendingString:[Constants formatTime:schedule.endDate withStyle:NSDateFormatterShortStyle]];
    //cell.creatorLabel.text = schedule.creatorName;
    
    /* If I've already joined one of the schedules, display this one first, distinguish it with a checkmark, and disable the join button on the other schedules
     
        if([self.mySchedules containsObject:schedule]) {
        cell.detailTextLabel.text = @"Joined";
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
     */
    
    cell.delegate = self;
    
    return cell;
}

/*!
 * Called when user taps Join button.
 * Asks user to enter the password if the schedule to join is private
 */
-(void)buttonPressed:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.scheduleToJoin = self.schedulesAssociatedWithThisHomeGame[indexPath.row];
    
    if([self.scheduleToJoin.privacy isEqualToString: @"private"]){
        
        //UIAlertView for password
        UIAlertView *enterPasswordAlertView = [[UIAlertView alloc]initWithTitle:kEnterPasswordAlertViewTitle message:nil delegate:self cancelButtonTitle:kCancelButtonTitle otherButtonTitles: kEnterButtonTitle, nil];
        
        enterPasswordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        
        [enterPasswordAlertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.firstOtherButtonIndex){ //enter
        UITextField *passwordTextField = [alertView textFieldAtIndex:0];
        NSString *passwordAttempt = passwordTextField.text;
        if([passwordAttempt isEqualToString:self.scheduleToJoin.password]){
            NSLog(@"Valid Password!");
            alertView.title = @"Success";
            
            //segue
            [self performSegueWithIdentifier:@"joinedSchedule" sender:self];
        
        }
        else{
            NSLog(@"Wrong Password");
            /*alertView.title = kWrongPasswordAlertViewTitle;
            alertView.message = kWrongPasswordAlertViewMessage;
            [alertView show];*/
            UIAlertView *wrongPasswordAlertView = [[UIAlertView alloc]initWithTitle:kWrongPasswordAlertViewTitle message:kWrongPasswordAlertViewMessage delegate:self cancelButtonTitle:kCancelButtonTitle otherButtonTitles: kEnterButtonTitle, nil];
            
            wrongPasswordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
            
            [wrongPasswordAlertView show];

        }
    }
}
-(IBAction)doneFilter:(UIStoryboardSegue *)segue
{
    self.schedulesAssociatedWithThisHomeGame = [self.schedulesAssociatedWithThisHomeGame sortedArrayUsingDescriptors:[self getSortDescriptors]];
    [self.tableView reloadData];
    
}
-(IBAction)cancelFilter:(UIStoryboardSegue *)segue
{
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue destinationViewController] isKindOfClass:[MySchedulesTableViewController class]]){
        MySchedulesTableViewController *mstvc = [segue destinationViewController];
        mstvc.scheduleToJoin = self.scheduleToJoin;
    }
}


@end
