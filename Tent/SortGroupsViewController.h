//
//  SortGroupsViewController.h
//  Tent
//
//  Created by Jeremy on 10/12/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortGroupsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSUInteger selectedRow;

@end
