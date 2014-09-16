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

#define kPersonClassName    @"Person"
#define kScheduleClassName  @"Schedule"

#define kSchedulePropertyName                   @"name"
#define kSchedulePropertyStartDate              @"startDate"
#define kSchedulePropertyEndDate                @"endDate"
#define kSchedulePropertyAvailabilitiesSchedule @"availabilitiesSchedule"
#define kSchedulePropertyAssignmentsSchedule    @"assignmentsSchedule"
#define kSchedulePropertyNumHourIntervals       @"numHourIntervals"
#define kSchedulePropertyPrivacy                @"privacy"
#define kSchedulePropertyPassword               @"password"
#define kSchedulePropertyHomeGameIndex          @"homeGameIndex"

#define kPrivacyValuePrivate                    @"private"
#define kPrivacyValuePublic                     @"public"

#define kUserPropertySchedulesList              @"schedulesList"



#define kEnterPasswordAlertViewTitle            @"Enter Password: "
#define kCancelButtonTitle                      @"Cancel"
#define kEnterButtonTitle                       @"Enter"

#define kWrongPasswordAlertViewTitle            @"Password Incorrect!"
#define kWrongPasswordAlertViewMessage          @"Please enter the password again."
@interface JoinScheduleTableViewController ()
@property (nonatomic) Schedule *scheduleToJoin;
@end

@implementation JoinScheduleTableViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
            for(PFObject *schedule in schedules){
                NSString *name = schedule[kSchedulePropertyName];
                NSMutableArray *availabilitiesSchedule = schedule[kSchedulePropertyAvailabilitiesSchedule];
                NSMutableArray *assignmentsSchedule = schedule[kSchedulePropertyAssignmentsSchedule];
                NSDate *startDate = schedule[kSchedulePropertyStartDate];
                NSDate *endDate = schedule[kSchedulePropertyEndDate];
                NSUInteger numHourIntervals = [schedule[kSchedulePropertyNumHourIntervals ] integerValue];
                NSString *privacy = schedule[kSchedulePropertyPrivacy];
                NSString *password = schedule[kSchedulePropertyPassword];
                NSUInteger homeGameIndex = [schedule[kSchedulePropertyHomeGameIndex] integerValue];
                
                NSString *objectID = schedule.objectId;
                
                Schedule *schedule = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex parseObjectID:objectID] ;
                
                [array addObject:schedule];
                self.schedulesAssociatedWithThisHomeGame = array;
                [self.tableView reloadData];

            }
        }
    }];

    
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
    //cell.creatorLabel.text = schedule.creatorName;
    
    cell.delegate = self;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
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
            
            //save to Parse
            
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
