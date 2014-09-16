//
//  HomeGamesTableViewCell.m
//  Tent
//
//  Created by Jeremy on 8/28/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "HomeGamesTableViewCell.h"

@implementation HomeGamesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

- (IBAction)joinButtonPressed:(id)sender {
    [self.delegate buttonPressed:self];
}
- (IBAction)createButtonPressed:(id)sender {
    [self.delegate buttonPressed:self];
}



@end
