//
//  StatsViewController.h
//  Tent
//
//  Created by Jeremy on 12/26/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"
#import "Person.h"
@interface StatsViewController : UIViewController

@property (nonatomic) Schedule *schedule;
@property (nonatomic) Person *person;

@end
