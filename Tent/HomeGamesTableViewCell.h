//
//  HomeGamesTableViewCell.h
//  Tent
//
//  Created by Jeremy on 8/28/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeGameTableViewCellDelegate;



@interface HomeGamesTableViewCell : UITableViewCell //maybe make this a subclass of JoinedTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UIView *joinButton;
@property (weak, nonatomic) IBOutlet UIView *createButton;
@property (weak, nonatomic) IBOutlet UILabel *gametimeLabel;

@property (nonatomic, weak) id<HomeGameTableViewCellDelegate> delegate;

- (IBAction)joinButtonPressed:(id)sender;
- (IBAction)createButtonPressed:(id)sender;

@end


@protocol HomeGameTableViewCellDelegate <NSObject>

-(void)buttonPressed:(UITableViewCell *)cell;

@end
