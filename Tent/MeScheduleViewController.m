//
//  MeScheduleViewController.m
//  Tent
//
//  Created by Jeremy on 12/25/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MeScheduleViewController.h"

@interface MeScheduleViewController ()

@end

@implementation MeScheduleViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*
    if([self.schedule.startDate timeIntervalSinceNow] < 0 && [self.schedule.endDate timeIntervalSinceNow] > 0){
        [self scrollToCurrentInterval];
        
    }
     */
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPerson = self.schedule.personsArray[[self.schedule findCurrentUserPersonIndex]]; //TODO: there was an error here when someone first joins a schedule. I think i may have fixed it
   
    // Do any additional setup after loading the view.
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
        self.currentPerson = self.schedule.personsArray[[self.schedule findCurrentUserPersonIndex]];
        self.updatedAvailabilitiesArray = nil;
        self.updatedIntervalDataByOverallRowArray = nil;
        //update UI if needed
        NSArray *changedProperties = userInfo[kUserInfoLocalScheduleChangedPropertiesKey];
        if([changedProperties containsObject:kUserInfoLocalSchedulePropertyPersonsArray]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
    
}


-(BOOL)isMe{
    return YES;
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
