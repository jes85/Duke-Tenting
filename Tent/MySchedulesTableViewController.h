//
//  MySchedulesTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Schedule;

@interface MySchedulesTableViewController : UITableViewController

@property (nonatomic) NSMutableArray *schedules;
@property (nonatomic) Schedule *scheduleToAdd;
@property (nonatomic) Schedule *scheduleToJoin;


// Unwind Segues
-(IBAction)createSchedule:(UIStoryboardSegue *)segue;
-(IBAction)joinedSchedule:(UIStoryboardSegue *)segue;

@end
