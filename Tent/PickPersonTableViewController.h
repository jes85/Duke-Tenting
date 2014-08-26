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
@property (nonatomic) NSString *addPersonName;
@property (nonatomic) Schedule *schedule;

-(IBAction)unWindToList:(UIStoryboardSegue *)segue;
-(IBAction)addPerson:(UIStoryboardSegue *)segue;
-(IBAction)cancelAddPerson:(UIStoryboardSegue *)segue;

@end
