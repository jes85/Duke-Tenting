//
//  MySchedulesTableViewCell.h
//  Tent
//
//  Created by Jeremy on 10/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySchedulesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *opponentLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;

@end
