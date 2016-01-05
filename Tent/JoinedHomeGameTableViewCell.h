//
//  JoinedHomeGameTableViewCell.h
//  Tent
//
//  Created by Jeremy on 11/16/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinedHomeGameTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *gametimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
