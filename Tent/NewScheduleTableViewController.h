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


@property (nonatomic) NSMutableSet *mySchedulesHomeGameIndexes;
@property (nonatomic) NSArray *homeGames;
@property (nonatomic) NSUInteger scrollRow;


-(IBAction)cancelCreateSchedule:(UIStoryboardSegue *)segue;
+(void)loadHomeGameScheduleDataFromParseWithBlock:(void (^) (NSArray *updatedHomeGamesArray, NSError *error))completionHander;



@property (nonatomic) NSString *test;

@end

