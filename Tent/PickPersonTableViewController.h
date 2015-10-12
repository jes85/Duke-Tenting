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

@property (nonatomic) NSString *addPersonName;
@property (nonatomic) Schedule *schedule;


-(IBAction)addPerson:(UIStoryboardSegue *)segue;
-(IBAction)cancelAddPerson:(UIStoryboardSegue *)segue;

-(IBAction)editAvailabilitiesReturn:(UIStoryboardSegue *)segue;
@end
