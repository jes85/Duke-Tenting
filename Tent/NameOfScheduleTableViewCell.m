//
//  NameOfScheduleTableViewCell.m
//  Tent
//
//  Created by Shrek on 8/12/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "NameOfScheduleTableViewCell.h"

@implementation NameOfScheduleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"Test");
        self.nameOfScheduleTextField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
