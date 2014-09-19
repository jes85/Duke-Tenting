//
//  ScheduleTableViewCell.h
//  Tent
//
//  Created by Jeremy on 9/1/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScheduleTableViewCellDelegate;


@interface ScheduleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPeopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *openClosedLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDate;

@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) id<ScheduleTableViewCellDelegate> delegate;

@end



@protocol ScheduleTableViewCellDelegate <NSObject>

-(void)buttonPressed: (UITableViewCell *)cell;

@end
