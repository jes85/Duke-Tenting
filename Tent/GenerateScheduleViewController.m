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

@interface GenerateScheduleViewController ()

@end

@implementation GenerateScheduleViewController

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) return;
    else if (buttonIndex==1){
        [self generateSchedule];
        [self.delegate generateScheduleViewControllerDidGenerateSchedule:self]; //do i have to switch views first?
    }
}
- (IBAction)generateScheduleButton:(UIButton *)sender {
    //first delete existing schedules?
    //pop up window to ask if they're sure
    
    
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Generate Schedule" message:@"Are you sure you want to generate a new schedule? The previous schedule data will be lost" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    
    [messageAlert show];
 
    
    
}

-(void)generateSchedule
{
    NSLog(@"Generating Schedule");
    [self.schedule setup];
        
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
        }
        
    }];
    
    
    
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
