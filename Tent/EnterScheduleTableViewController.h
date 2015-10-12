//
//  EnterScheduleTableViewController.h
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "Schedule.h"

@interface EnterScheduleTableViewController : UITableViewController

@property (nonatomic, weak) Person *currentPerson;

@property (nonatomic) Schedule *schedule;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;


@end
