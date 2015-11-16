//
//  NewScheduleTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeGamesTableViewCell.h"

@interface NewScheduleTableViewController : UITableViewController <HomeGameTableViewCellDelegate, UIAlertViewDelegate>


@property (nonatomic) NSMutableArray *publicSchedules;
@property (nonatomic) NSMutableSet *mySchedulesHomeGameIndexes;
@property (nonatomic) NSArray *homeGames;
@property (nonatomic) NSUInteger scrollRow;
@property (nonatomic) NSString *test;


-(IBAction)cancelCreateSchedule:(UIStoryboardSegue *)segue;
+(void)loadHomeGameScheduleDataFromParseWithBlock:(void (^) (NSArray *updatedHomeGamesArray, NSError *error))completionHander;

@end

