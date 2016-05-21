//
//  SuperPersonsInIntervalViewController.h
//  Tent
//
//  Created by Jeremy on 1/2/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Schedule.h"
#import "Interval.h"

@interface SuperPersonsInIntervalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Interval *interval;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

+(NSInteger)findCurrentTimeIntervalIndexForSchedule:(Schedule *)schedule;
@end
