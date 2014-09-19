//
//  MySchedulesTableViewController.m
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "MySchedulesTableViewController.h"
#import "Schedule.h"
#import <Parse/Parse.h>
#import "CreateScheduleTableViewController.h"
#import "NameOfScheduleTableViewCell.h"
#import "HomeBaseTableViewController.h"
#import "NewScheduleTableViewController.h"
#import "Constants.h"

@interface MySchedulesTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addScheduleButton;
@property (nonatomic) NSMutableArray *publicSchedules;

@end


@implementation MySchedulesTableViewController


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


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getMySchedules];
    
}

/*!
 *  Query Parse to retrieve schedules that current user is a part of
 */
-(void)getMySchedules
{
    PFRelation *relation = [[PFUser currentUser] relationForKey:kUserPropertySchedulesList];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedulesForThisUser, NSError *error) {
        self.schedules = nil;
        if(!error){
            for(PFObject *schedule in schedulesForThisUser){
                NSString *name = schedule[kSchedulePropertyName];
                NSMutableArray *availabilitiesSchedule = schedule[kSchedulePropertyAvailabilitiesSchedule];
                NSMutableArray *assignmentsSchedule = schedule[kSchedulePropertyAssignmentsSchedule];
                NSDate *startDate = schedule[kSchedulePropertyStartDate];
                NSDate *endDate = schedule[kSchedulePropertyEndDate];
                NSUInteger numHourIntervals = [schedule[kSchedulePropertyNumHourIntervals ] integerValue];
                NSString *privacy = schedule[kSchedulePropertyPrivacy];
                NSString *password = schedule[kSchedulePropertyPassword];
                NSUInteger homeGameIndex = [schedule[kSchedulePropertyHomeGameIndex] integerValue];
                
                Schedule *schedule = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex] ;
                
                [self.schedules addObject:schedule];
            }
        }
        else{
            NSLog(@"error retrieving user's schedules from parse");
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
            NSString *name = parseSchedule[kSchedulePropertyName];
            NSMutableArray *availabilitiesSchedule = parseSchedule[kSchedulePropertyAvailabilitiesSchedule];
            NSMutableArray *assignmentsSchedule = parseSchedule[kSchedulePropertyAssignmentsSchedule];
            NSDate *startDate = parseSchedule[kSchedulePropertyStartDate];
            NSDate *endDate = parseSchedule[kSchedulePropertyEndDate];
            NSUInteger numHourIntervals = [parseSchedule[kSchedulePropertyNumHourIntervals ] integerValue];
            NSString *privacy = parseSchedule[kSchedulePropertyPrivacy];
            NSString *password = parseSchedule[kSchedulePropertyPassword];
            NSUInteger homeGameIndex = [parseSchedule[kSchedulePropertyHomeGameIndex] integerValue];
            
            NSMutableArray *zeroesArray =[self createZeroesArrayOfLength: numHourIntervals];
            
            
            PFObject *personObject = [PFObject objectWithClassName:kPersonClassName];
            personObject[kPersonPropertyName] = [[PFUser currentUser] objectForKey:kUserPropertyFullName];
            personObject[kPersonPropertyIndex] = [NSNumber numberWithInteger:[availabilitiesSchedule count]];
            personObject[kPersonPropertyAvailabilitiesArray] = zeroesArray;
            personObject[kPersonPropertyAssignmentsArray] = zeroesArray;
            
            
            [availabilitiesSchedule addObject:[zeroesArray copy]];
            [assignmentsSchedule addObject:[zeroesArray copy]];
            
            parseSchedule[kSchedulePropertyAvailabilitiesSchedule] = availabilitiesSchedule;
            parseSchedule[kSchedulePropertyAssignmentsSchedule] = assignmentsSchedule;
            
            
            Schedule *joinedSchedule = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex] ;

           
            personObject[@"scheduleName"] = joinedSchedule.name; //change this to a PFRelation to the schedule
            [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    PFRelation *relation = [parseSchedule relationForKey:kSchedulePropertyPersonsList];
                    [relation addObject:personObject];
                    
                   

                    [parseSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if(!error){
                         PFRelation *relation = [[PFUser currentUser] relationForKey:kUserPropertySchedulesList];
                         [relation addObject:parseSchedule];
                         [[PFUser currentUser] saveInBackground];
                         [self.schedules addObject:joinedSchedule];
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
    
    if([[segue destinationViewController] isKindOfClass:[HomeBaseTableViewController class]]){
        HomeBaseTableViewController *hbtvc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            hbtvc.schedule = self.schedules[indexPath.row];
            hbtvc.navigationItem.title = hbtvc.schedule.name;
        }
    }
    else if(sender==self.addScheduleButton){
        NewScheduleTableViewController *nstvc = [segue destinationViewController];
        nstvc.publicSchedules = self.publicSchedules;
        nstvc.mySchedules = self.schedules;
    }
}


@end
