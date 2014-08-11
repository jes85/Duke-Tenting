//
//  PickPersonTableViewController.h
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Schedule.h"

@interface PickPersonTableViewController : UITableViewController


@property (nonatomic) NSMutableArray *people;

-(IBAction)unWindToList:(UIStoryboardSegue *)segue;

-(IBAction)addPerson:(UIStoryboardSegue *)segue;
-(IBAction)cancelAddPerson:(UIStoryboardSegue *)segue;

@property (nonatomic) NSString *addPersonName;
@property (nonatomic) NSUInteger numIntervals;//try to figure out away to have this information in one place (NSNotification center?)
@property (nonatomic)NSArray *hourIntervalsDisplayArray;


@property (nonatomic) Schedule *schedule;
@end
