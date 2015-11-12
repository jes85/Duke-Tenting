//
//  PersonsInIntervalTableViewController.h
//  Tent
//
//  Created by Shrek on 8/5/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"
@interface PersonsInIntervalTableViewController : UITableViewController

@property (nonatomic) NSArray *availablePersonsArray;
@property (nonatomic) NSArray *assignedPersonsArray;

@end
