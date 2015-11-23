//
//  ScheduleSettingsViewController.h
//  Tent
//
//  Created by Jeremy on 10/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"

@interface ScheduleSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSDictionary *settings;
@property (nonatomic) BOOL isCreator;
@property (nonatomic) Schedule *schedule;
@end
