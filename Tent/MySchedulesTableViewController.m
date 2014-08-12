//
//  MySchedulesTableViewController.m
//  Tent
//
//  Created by Shrek on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "MySchedulesTableViewController.h"
#import "Schedule.h"
#import <Parse/Parse.h>
#import "AddSchedulesTableViewController.h"
#import "NameOfScheduleTableViewCell.h"
#import "HomeBaseTableViewController.h"


@implementation MySchedulesTableViewController

-(NSMutableArray *)schedules{
    if(!_schedules)_schedules = [[NSMutableArray alloc]init];
    return _schedules;
}


/*! Find schedules in Parse, update self.schedules propery and reload table view controller to show data
 */
-(void)updateSchedules
{
    PFQuery *query = [PFQuery queryWithClassName:@"Schedule"];
    //query where some ID says its my schedule
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedules, NSError *error) {
        if(!schedules){
            NSLog(@"Find failed");
        }else if ([schedules count]<1){
            NSLog(@"No My Schedules in Parse");
        }else{
            NSLog(@"Find My Schedules succeeded");
            for(PFObject *schedule in schedules){
                NSString *name = schedule[@"name"];
                NSMutableArray *availabilitiesSchedule = schedule[@"availabilitiesSchedule"];
                 NSMutableArray *assignmentsSchedule = schedule[@"assignmentsSchedule"];
                NSDate *startDate = schedule[@"startDate"];
                NSDate *endDate = schedule[@"endDate"];
                NSUInteger numHourIntervals = [schedule[@"numHourIntervals"] integerValue];
                
                Schedule *schedule = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate] ;
                
                [self.schedules addObject:schedule];
            }
            
        }
        [self.tableView reloadData];
    }];


}
#pragma mark - View Controller Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateSchedules];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
         }
     }
 }


-(IBAction)addSchedule:(UIStoryboardSegue *)segue
{
    //Schedule should implement copy protocol
    //Schedule *newSchedule = [self.scheduleToAdd copy];
    //[self.schedules addObject:newSchedule];
    //self.scheduleToAdd = nil;
    
    Schedule *newSchedule = self.scheduleToAdd;
    [self.schedules addObject:newSchedule];
    
    [self.tableView reloadData];
    
    PFObject *scheduleObject = [PFObject objectWithClassName:@"Schedule"];
    scheduleObject[@"name"] = newSchedule.name;
    scheduleObject[@"startDate"] = newSchedule.startDate;
    scheduleObject[@"endDate"] = newSchedule.endDate;
    scheduleObject[@"availabilitiesSchedule"] = newSchedule.availabilitiesSchedule;
    scheduleObject[@"assignmentsSchedule"] = newSchedule.assignmentsSchedule;
    scheduleObject[@"numHourIntervals"] = [NSNumber numberWithInteger:newSchedule.numHourIntervals];
    
    [scheduleObject saveInBackground];
    
    
}
-(IBAction)cancelAddSchedule:(UIStoryboardSegue *)segue
{
    
}

@end
