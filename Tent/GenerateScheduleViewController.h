//
//  GenerateScheduleViewController.h
//  Tent
//
//  Created by Shrek on 7/25/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GenerateScheduleViewController;

@protocol GenerateScheduleViewControllerDelegate <NSObject>

//-(void)generateScheduleViewControllerDidCancel:(GenerateScheduleViewController *)controller;
-(void)generateScheduleViewControllerDidGenerateSchedule:(GenerateScheduleViewController *)controller;

@end

@interface GenerateScheduleViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic, assign) id<GenerateScheduleViewControllerDelegate> delegate;


// I might not need these since I'm saving to Parse
@property(nonatomic, strong) NSMutableArray *availabilitiesSchedule;
@property(nonatomic, strong) NSMutableArray *assignmentsSchedule;


@end

