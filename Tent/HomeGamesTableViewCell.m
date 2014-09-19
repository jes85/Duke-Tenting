//
//  HomeGamesTableViewCell.m
//  Tent
//
//  Created by Jeremy on 8/28/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "HomeGamesTableViewCell.h"

@implementation HomeGamesTableViewCell


- (IBAction)joinButtonPressed:(id)sender {
    [self.delegate buttonPressed:self];
}
- (IBAction)createButtonPressed:(id)sender {
    [self.delegate buttonPressed:self];
}



@end
