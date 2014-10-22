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
static NSString *kGenerateScheduleErrorID = @"Error";

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
    if(![self.schedule setup]){//this does everthing to generate the assignments schedule. returns false if there's an error
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:kGenerateScheduleErrorID message:@"Generate Schedule unsuccessful. Probably not enough people available in one or more intervals." delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil];
        
        [errorAlert show];
        return;
    };
   
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
        if(error){
            [self clearAssignments];
            
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:kGenerateScheduleErrorID message:@"The assignments schedule was not successfully generated. Probably an internet issue" delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil];
            [errorAlert show];
        }
        for(PFObject *object in objects){
            NSNumber *index = object[@"index"];
            object[@"assignmentsArray"] = self.schedule.assignmentsSchedule[[index intValue]];
            [object saveInBackground];
        }
        UIAlertView *successAlert = [[UIAlertView alloc]initWithTitle:kGenerateScheduleFinishedID message:@"The assignments schedule was successfully generated." delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil];
        
        [successAlert show];
    }];
    
    
    
}
- (IBAction)clearAssignmentsButton:(id)sender {
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:kClearAssignmentsID message:@"Are you sure? The assignments schedule will be lost. Availabilities will not be changed." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    
    [messageAlert show];

}
-(void)clearAssignments{
    //EDIT: write method to clear all assignments
    
}
- (IBAction)clearAvailabilititesAndAssignments:(id)sender {
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:kClearAllID message:@"Are you sure? The availabilities schedule and the assignments schedule will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    
    [messageAlert show];
}

-(void)clearAvailabilities
{
    //EDIT: write method to clear all availabilities
}

@end
