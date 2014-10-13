//
//  JoinScheduleTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/31/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleTableViewCell.h"

@interface JoinScheduleTableViewController : UITableViewController <ScheduleTableViewCellDelegate, UIAlertViewDelegate>

@property (nonatomic) NSArray *schedulesAssociatedWithThisHomeGame;
@property (nonatomic) NSUInteger homeGameIndex;

@end
