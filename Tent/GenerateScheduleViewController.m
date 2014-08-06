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

@interface GenerateScheduleViewController ()

@end

@implementation GenerateScheduleViewController

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) return;
    else if (buttonIndex==1){
        [self generateSchedule];
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
    PFQuery *query = [PFQuery queryWithClassName:@"Schedule"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.availabilitiesSchedule = object[@"availabilitiesSchedule"];
        //Schedule *schedule = [[Schedule alloc]initWithNumPeople:[self.availabilitiesSchedule count] withNumIntervals:[self.availabilitiesSchedule[0] count]];
        Schedule *schedule = [[Schedule alloc]initWithAvailabilitiesSchedule:self.availabilitiesSchedule];
        schedule.availabilitiesSchedule = self.availabilitiesSchedule;
        
        
        [schedule setup];
        
        
        object[@"assignmentsSchedule"] = schedule.assignmentsSchedule;
        self.assignmentsSchedule = schedule.assignmentsSchedule;
        
        
        [object saveInBackground];
        
    }];
    
    // Create and same assignmentsArray for each person
    PFQuery *query2 = [PFQuery queryWithClassName:@"Person"];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for(PFObject *object in objects){
            NSNumber *index = object[@"index"];
            object[@"assignmentsArray"] = self.assignmentsSchedule[[index intValue]];
            [object saveInBackground];
        }
        
    }];
    
    
    
}


@end
