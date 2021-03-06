//
//  NewScheduleTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeGamesTableViewCell.h"
#import <Parse/Parse.h>
#import "HomeGame.h"

@interface NewScheduleTableViewController : UITableViewController <HomeGameTableViewCellDelegate, UIAlertViewDelegate>


@property (nonatomic) NSMutableSet *mySchedulesHomeGameParseIds;
@property (nonatomic) NSArray *homeGames;
@property (nonatomic) NSUInteger scrollRow;


-(IBAction)cancelCreateSchedule:(UIStoryboardSegue *)segue;
+(void)loadHomeGameScheduleDataFromParseWithBlock:(void (^) (NSArray *parseHomeGames, NSArray *updatedHomeGamesArray, NSError *error))completionHandler;
+(HomeGame *)homeGameObjectFromParseHomeGame:(PFObject *)parseHomeGame;


@property (nonatomic) NSString *test;

@end

