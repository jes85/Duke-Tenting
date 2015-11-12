//
//  PersonsInIntervalViewController.h
//  Tent
//
//  Created by Jeremy on 11/12/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"

@interface PersonsInIntervalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *availablePersonsArray;
@property (nonatomic) NSArray *assignedPersonsArray;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic) BOOL displayCurrent;
@property (nonatomic) Schedule *schedule;

@end
