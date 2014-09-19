//
//  PasswordTableViewCell.h
//  Tent
//
//  Created by Jeremy on 8/30/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@end
