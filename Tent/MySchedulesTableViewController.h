//
//  MySchedulesTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class Schedule;


@interface MySchedulesTableViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic) NSMutableArray *schedules;
@property (nonatomic) Schedule *scheduleToAdd;
@property (nonatomic) Schedule *scheduleToJoin;
@property (nonatomic) NSArray *homeGames;
@property (nonatomic) NSString *test;

// Unwind Segues
-(IBAction)createSchedule:(UIStoryboardSegue *)segue;
-(IBAction)joinedSchedule:(UIStoryboardSegue *)segue;

+(Schedule *)createScheduleObjectFromParseInfo: (PFObject *)parseSchedule;

-(IBAction)closeSettings:(UIStoryboardSegue *)segue;

@end
