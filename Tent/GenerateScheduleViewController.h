//
//  GenerateScheduleViewController.h
//  Tent
//
//  Created by Shrek on 7/25/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Schedule;
@class GenerateScheduleViewController;

@protocol GenerateScheduleViewControllerDelegate <NSObject>

//-(void)generateScheduleViewControllerDidCancel:(GenerateScheduleViewController *)controller;
-(void)generateScheduleViewControllerDidGenerateSchedule:(GenerateScheduleViewController *)controller;

@end

@interface GenerateScheduleViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic, assign) id<GenerateScheduleViewControllerDelegate> delegate;

@property(nonatomic, strong) Schedule *schedule;


@end

