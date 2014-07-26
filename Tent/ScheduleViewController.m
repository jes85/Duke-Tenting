//
//  ScheduleViewController.m
//  Tent
//
//  Created by Shrek on 7/3/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "ScheduleViewController.h"
#import "Availablities.h"

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Availablities makeMatrix];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
