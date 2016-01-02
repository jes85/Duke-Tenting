//
//  NowPersonsInIntervalViewController.m
//  Tent
//
//  Created by Jeremy on 12/23/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "NowPersonsInIntervalViewController.h"
#import "Constants.h"

@interface NowPersonsInIntervalViewController ()


@end

@implementation NowPersonsInIntervalViewController
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updatePersonsArraysForCurrentTimeInterval];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
    self.dateTimeLabel.text = self.dateTimeText;
    [self.view addSubview:self.dateTimeLabel];
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleChanged:) name:kNotificationNameScheduleChanged object:nil];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}
-(void)scheduleChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if(!(notification.object == self)){
        Schedule *schedule = userInfo[kUserInfoLocalScheduleKey];
        //update data
        self.schedule = schedule;
        //update UI if needed
        NSArray *changedProperties = userInfo[kUserInfoLocalScheduleChangedPropertiesKey];
        if([changedProperties containsObject:kUserInfoLocalSchedulePropertyPersonsArray]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
    }
    
    
}


-(void)updatePersonsArraysForCurrentTimeInterval
{
    //TODO: Maybe have schedule status be a property
    // Schedule Has Not Started
    if([self.schedule.startDate timeIntervalSinceNow] > 0 ){
        self.dateTimeLabel.text = @"Schedule has not started yet.";
        return;
        
    }
    // Schedule is Over
    if([self.schedule.endDate timeIntervalSinceNow] < 0 ){
        self.dateTimeLabel.text = @"Schedule is over.";
        return;
        
    }
    // Schedule is In Progress
    NSInteger index = [SuperPersonsInIntervalViewController findCurrentTimeIntervalIndexForSchedule:self.schedule];
    Interval *interval = self.schedule.intervalDataByOverallRow[index];
    self.interval = interval;
    self.dateTimeLabel.text = interval.dateTimeString;
    [self.tableView reloadData];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
