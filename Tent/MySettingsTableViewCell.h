//
//  MySettingsTableViewCell.h
//  Tent
//
//  Created by Jeremy on 10/16/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *settingNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingValueLabel;

@end
