//
//  MeScheduleViewController.m
//  Tent
//
//  Created by Jeremy on 12/25/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MeScheduleViewController.h"

#import "Interval.h"
#import <EventKit/EventKit.h>
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
- (IBAction)exportToCalendarButtonPressed:(id)sender {
    [self exportScheduleToCalendar];
}
-(void)exportScheduleToCalendar
{
    Person *person =self.schedule.personsArray[[self.schedule findCurrentUserPersonIndex]];
    NSDate *startDate;
    NSDate *endDate;
    BOOL streakInProgress = false;
    NSString *title = [NSString stringWithFormat:@"K-Ville: %@", self.schedule.homeGame.opponentName];
    for(int i = 0; i<person.assignmentsArray.count; i++){
        if([person.assignmentsArray[i] integerValue] == 2){ //beginning of streak or continue streak
            if(!streakInProgress){ //start new streak
                Interval *interval = self.schedule.intervalDataByOverallRow[i];
                startDate = interval.startDate;
                streakInProgress = true;
            }
            
        }else{ //end of streak or continue non-streak
            if(streakInProgress){ //end streak
                Interval *interval = self.schedule.intervalDataByOverallRow[i-1];
                endDate = interval.endDate;
                streakInProgress = false;
                [self createEventWithTitle:title startDate:startDate endDate:endDate];
                startDate = nil; // to catch errors in my code
                endDate = nil;
                
            }
        }
    }
    if(streakInProgress){ //last streak includes last interval
        Interval *interval = self.schedule.intervalDataByOverallRow[person.assignmentsArray.count-1];
        endDate = interval.endDate;
        [self createEventWithTitle:title startDate:startDate endDate:endDate];
    }
}
-(void)createEventWithTitle:(NSString *)title startDate:(NSDate *)startDate endDate: (NSDate *)endDate
{
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = title;
        event.startDate = startDate;
        event.endDate = endDate;
        event.calendar = [store defaultCalendarForNewEvents];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        //self.savedEventId = event.eventIdentifier;  //save the event id if you want to access this later
    }];
    
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
