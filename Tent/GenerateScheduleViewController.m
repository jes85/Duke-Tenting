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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)generateScheduleButton:(UIButton *)sender {
    //first delete existing schedules?
    //pop up window to ask if they're sure
    
    /*PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
           
            self.availabilitiesSchedule = [[NSMutableArray alloc] initWithArray:objects];
            PFObject *scheduleObject = [PFObject objectWithClassName:@"Schedule"];
            scheduleObject[@"availabilitiesSchedule"]=self.availabilitiesSchedule;
            //NSLog(@"%@", availabilitiesSchedule[0]);
            [scheduleObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    Schedule *schedule = [[Schedule alloc]initWithNumPeople:[self.availabilitiesSchedule count] withNumIntervals:[self.availabilitiesSchedule[0] count]];
                    schedule.availabilitiesSchedule = self.availabilitiesSchedule;
                    [schedule setup];
                }
            }];
            
        } else {
            NSLog(@"Error retreving array of availabilities arrays");
        }
    }];
     */
     
     PFQuery *query = [PFQuery queryWithClassName:@"Schedule"];
    [query whereKey:@"type" equalTo:@"availabilities"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.availabilitiesSchedule = object[@"availabilitiesSchedule"];
        Schedule *schedule = [[Schedule alloc]initWithNumPeople:[self.availabilitiesSchedule count] withNumIntervals:[self.availabilitiesSchedule[0] count]];
        schedule.availabilitiesSchedule = self.availabilitiesSchedule;
       

        [schedule setup];
        object[@"assignmentsSchedule"] = schedule.assignmentsSchedule;
        self.assignmentsSchedule = schedule.assignmentsSchedule;
        

        [object saveInBackground];

    }];
    PFQuery *query2 = [PFQuery queryWithClassName:@"Person"];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for(PFObject *object in objects){
            NSNumber *index = object[@"index"];
            object[@"assignmentsArray"] = self.assignmentsSchedule[[index intValue]];
            //NSLog(@"assignmentsArray %@", object[@"assignmentsArray"]);

            [object saveInBackground];
        }
        
    }];

    
     
    
    
}


@end
