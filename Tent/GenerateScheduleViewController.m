//
//  GenerateScheduleViewController.m
//  Tent
//
//  Created by Shrek on 7/25/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "GenerateScheduleViewController.h"
#import <Parse/Parse.h>
#import "Schedule.h"
#import "HomeBaseTableViewController.h"


static NSString *kGenerateScheduleID = @"Generate Schedule";
static NSString *kClearAssignmentsID = @"Clear Assignments";
static NSString *kClearAllID = @"Clear All";
static NSString *kGenerateScheduleFinishedID = @"Success!";

@interface GenerateScheduleViewController ()

@end

@implementation GenerateScheduleViewController

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) return;
    else if (buttonIndex==1){
        if([alertView.title isEqualToString:kGenerateScheduleID])
        {
            [self generateSchedule];
            [self.delegate generateScheduleViewControllerDidGenerateSchedule:self]; //do i have to switch views first?
        }
        else if([alertView.title isEqualToString:kClearAssignmentsID])
        {
            [self clearAssignments];
        }
        else if([alertView.title isEqualToString:kClearAllID])
        {
            [self clearAssignments];
            [self clearAvailabilities];
        }
    }
}
- (IBAction)generateScheduleButton:(UIButton *)sender {
    //first delete existing schedules?
    //pop up window to ask if they're sure
    
    
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:kGenerateScheduleID message:@"Are you sure you want to generate a new schedule? The previous schedule data will be lost" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    
    [messageAlert show];
 
    
    
}

-(void)generateSchedule
{
    NSLog(@"Generating Schedule");
    [self.schedule setup];//this does everthing to generate the assignments schedule
   
    PFQuery *query = [PFQuery queryWithClassName:@"Schedule"];
    [query whereKey:@"name" equalTo:self.schedule.name];//change to schedule ID later
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
  
        object[@"assignmentsSchedule"] = self.schedule.assignmentsSchedule;
        [object saveInBackground];
        
    }];
    
    // Create and same assignmentsArray for each person
    PFQuery *query2 = [PFQuery queryWithClassName:@"Person"];
    [query2 whereKey:@"scheduleName" equalTo:self.schedule.name];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for(PFObject *object in objects){
            NSNumber *index = object[@"index"];
            object[@"assignmentsArray"] = self.schedule.assignmentsSchedule[[index intValue]];
            [object saveInBackground];
            UIAlertView *messageAlert = [[UIAlertView alloc]initWithTitle:kGenerateScheduleFinishedID message:@"The assignments schedule was successfully generated" delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil];
            
            [messageAlert show];
        }
        
    }];
    
    
    
}
- (IBAction)clearAssignmentsButton:(id)sender {
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:kClearAssignmentsID message:@"Are you sure? The assignments schedule will be lost. Availabilities will not be changed." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    
    [messageAlert show];

}
-(void)clearAssignments{
    
}
- (IBAction)clearAvailabilititesAndAssignments:(id)sender {
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:kClearAllID message:@"Are you sure? The availabilities schedule and the assignments schedule will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    
    [messageAlert show];
}

-(void)clearAvailabilities
{
    
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue destinationViewController] isKindOfClass:[HomeBaseTableViewController class]]){
        HomeBaseTableViewController *homeBase = [segue destinationViewController];
        homeBase.schedule = self.schedule; //unnecessary since the point to the same place
    }
}*/

@end
