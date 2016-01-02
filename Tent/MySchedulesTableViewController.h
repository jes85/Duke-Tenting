//
//  MySchedulesTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
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

+(Schedule *)createScheduleObjectFromParseInfo: (PFObject *)parseSchedule; //TODO: maybe method move to another class

-(IBAction)closeSettings:(UIStoryboardSegue *)segue;
-(IBAction)scheduleDeleted:(UIStoryboardSegue *)segue;

+(void)removeSchedulesFromCurrentUser:(NSArray *)scheduleIds;

@end
