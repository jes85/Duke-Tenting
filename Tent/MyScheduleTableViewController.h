//
//  MyScheduleTableViewController.h
//  Tent
//
//  Created by Jeremy on 10/9/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "Schedule.h"

@interface MyScheduleTableViewController : UITableViewController

@property (nonatomic) Person *currentPerson;
@property (nonatomic) Schedule *schedule;

-(void)saveEdits;
@end
