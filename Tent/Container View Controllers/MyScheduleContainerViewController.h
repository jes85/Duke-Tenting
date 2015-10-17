//
//  MyScheduleContainerViewController.h
//  Tent
//
//  Created by Jeremy on 10/8/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"
@interface MyScheduleContainerViewController : UIViewController

@property (nonatomic) NSArray *viewControllers;
@property (nonatomic) Schedule *schedule;
@property (nonatomic) NSString *opponentName;//incorporate opponent in schedule object

-(void)refreshData;


@end
