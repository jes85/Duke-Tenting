//
//  HomeGamesTableViewCell.h
//  Tent
//
//  Created by Jeremy on 8/28/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeGameTableViewCellDelegate;



@interface HomeGamesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *joinButton;
@property (weak, nonatomic) IBOutlet UIView *createButton;

@property (nonatomic, weak) id<HomeGameTableViewCellDelegate> delegate;

- (IBAction)joinButtonPressed:(id)sender;
- (IBAction)createButtonPressed:(id)sender;

@end


@protocol HomeGameTableViewCellDelegate <NSObject>

-(void)buttonPressed:(UITableViewCell *)cell;

@end
