//
//  ScheduleTableViewCell.m
//  Tent
//
//  Created by Jeremy on 9/1/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "ScheduleTableViewCell.h"

@implementation ScheduleTableViewCell

- (IBAction)joinButtonPressed:(id)sender {
    [self.delegate buttonPressed:self];
}

@end
