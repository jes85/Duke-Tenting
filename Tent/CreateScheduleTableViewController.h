//
//  CreateScheduleTableViewController.h
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeGame.h"

@interface CreateScheduleTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic) HomeGame *homeGame;
@end
