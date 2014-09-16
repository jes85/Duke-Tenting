//
//  NewScheduleTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeGamesTableViewCell.h"

@interface NewScheduleTableViewController : UITableViewController <HomeGameTableViewCellDelegate>


@property (nonatomic) NSMutableArray *publicSchedules;
@property (nonatomic) NSMutableArray *mySchedules;
@end
