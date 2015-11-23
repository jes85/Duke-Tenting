//
//  JoinScheduleTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/31/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleTableViewCell.h"
#import "HomeGame.h"

@interface JoinScheduleTableViewController : UITableViewController <ScheduleTableViewCellDelegate>

@property (nonatomic) NSArray *schedulesAssociatedWithThisHomeGame;
@property (nonatomic) HomeGame *homeGame;
@property (nonatomic) NSUInteger filterBy;

-(IBAction)doneFilter:(UIStoryboardSegue *)segue;
-(IBAction)cancelFilter:(UIStoryboardSegue *)segue;
@end
