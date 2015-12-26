//
//  MyScheduleViewController.h
//  Tent
//
//  Created by Jeremy on 12/25/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "Schedule.h"

@interface MyScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Person *currentPerson;
@property (nonatomic) Schedule *schedule;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)saveEdits;
@end
