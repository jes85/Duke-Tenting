//
//  PersonsInIntervalViewController.m
//  Tent
//
//  Created by Jeremy on 11/12/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "PersonsInIntervalViewController.h"

@interface PersonsInIntervalViewController ()

@end

@implementation PersonsInIntervalViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.dateTimeLabel.text = self.interval.dateTimeString;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
