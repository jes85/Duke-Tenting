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
@property (nonatomic) NSString *dateTimeText;


@property (nonatomic) BOOL displayCurrent;
@property (nonatomic) Schedule *schedule;


+(NSInteger)findCurrentTimeIntervalIndexForSchedule:(Schedule *)schedule;

@end
