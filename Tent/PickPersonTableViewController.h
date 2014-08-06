//
//  PickPersonTableViewController.h
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PickPersonTableViewController : UITableViewController


@property (nonatomic) NSMutableArray *people;

-(IBAction)unWindToList:(UIStoryboardSegue *)segue;

@end
