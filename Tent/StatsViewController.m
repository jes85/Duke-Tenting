//
//  StatsViewController.m
//  Tent
//
//  Created by Jeremy on 12/26/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "StatsViewController.h"
#import "Interval.h"
#import "Constants.h"
@interface StatsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *minutesAssignedLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesAvailableLabel;
@property (weak, nonatomic) IBOutlet UILabel *nightsAssignedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nightsAvailableLabel;

@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    self.navigationItem.title = self.person.user ? [self.person.user objectForKey:kUserPropertyFullName] : self.person.offlineName;
    
    NSArray *dayInfo = [self calculateMinutesAvailableAndAssigned];
    NSUInteger dayTotalMinutesAvailable = [dayInfo[0] unsignedIntegerValue];
    NSUInteger dayTotalMinutesAssigned = [dayInfo[1] unsignedIntegerValue];
    
    /*
    NSUInteger dayHoursAvailable = dayTotalMinutesAvailable / 60;
    NSUInteger dayMinutesAvailable = dayTotalMinutesAvailable % 60;
    
    
    NSUInteger dayHoursAssigned = dayTotalMinutesAssigned / 60;
    NSUInteger dayMinutesAssigned = dayTotalMinutesAssigned % 60;
     */
    
    NSArray *nightStats = [self calculateNightsAvailableAndAssigned];
    NSUInteger nightsAvailable = [nightStats[0] unsignedIntegerValue];
    NSUInteger nightsAssigned = [nightStats[1] unsignedIntegerValue];

    

    self.minutesAvailableLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)dayTotalMinutesAvailable];
    self.minutesAssignedLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)dayTotalMinutesAssigned];
    self.nightsAvailableLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)nightsAvailable];
    self.nightsAssignedLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)nightsAssigned];
    
    
    // Testing
    //[self calculateTotalNightAndDayIntervalsAvailableAndAssigned];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)calculateNightsAvailableAndAssigned
{
    NSUInteger nightsAvailable = 0;
    NSUInteger nightsAssigned = 0
    
    ;
    for(int i = 0; i <self.person.assignmentsArray.count; i++){
        
        NSUInteger intervalStatus = [self.person.assignmentsArray[i] unsignedIntegerValue];
        if(intervalStatus != 0){
            Interval *interval = self.schedule.intervalDataByOverallRow[i];
            if(!interval.night) continue;
            if(intervalStatus == 2){
                nightsAssigned += 1;
                nightsAvailable += 1;
            }
            else if(intervalStatus == 1){
                nightsAvailable += 1;
                
            }
            
        }
    }
    return @[[NSNumber numberWithUnsignedInteger:nightsAvailable], [NSNumber numberWithUnsignedInteger:nightsAssigned]];
}
-(NSArray *)calculateDayMinutesAvailableAndAssigned
{
    NSUInteger minutesAvailable = 0;
    NSUInteger minutesAssigned = 0
    
    ;
    for(int i = 0; i <self.person.assignmentsArray.count; i++){
        
        NSUInteger intervalStatus = [self.person.assignmentsArray[i] unsignedIntegerValue];
        if(intervalStatus != 0){
            Interval *interval = self.schedule.intervalDataByOverallRow[i];
            if(interval.night) continue;
            NSUInteger seconds = [interval.endDate timeIntervalSinceDate:interval.startDate];
            NSUInteger minutes = seconds/60;
            if(intervalStatus == 2){
                minutesAssigned += minutes;
                minutesAvailable += minutes;
            }
            else if(intervalStatus == 1){
                minutesAvailable += minutes;
                
            }
            
        }
    }
    
    return @[[NSNumber numberWithUnsignedInteger:minutesAvailable], [NSNumber numberWithUnsignedInteger:minutesAssigned]];
}
-(NSArray *)calculateMinutesAvailableAndAssigned
{
    NSUInteger minutesAvailable = 0;
    NSUInteger minutesAssigned = 0
    
    ;
    for(int i = 0; i <self.person.assignmentsArray.count; i++){
       
        NSUInteger intervalStatus = [self.person.assignmentsArray[i] unsignedIntegerValue];
        if(intervalStatus != 0){
            Interval *interval = self.schedule.intervalDataByOverallRow[i];
            NSUInteger seconds = [interval.endDate timeIntervalSinceDate:interval.startDate];
            NSUInteger minutes = seconds/60;
            if(intervalStatus == 2){
                minutesAssigned += minutes;
                minutesAvailable += minutes;
            }
            else if(intervalStatus == 1){
                minutesAvailable += minutes;

            }
            
        }
    }
    
    return @[[NSNumber numberWithUnsignedInteger:minutesAvailable], [NSNumber numberWithUnsignedInteger:minutesAssigned]];
}

// For testing
-(void)calculateTotalNightAndDayIntervalsAvailableAndAssigned
{
    NSUInteger dayIntervalsAvailable = 0;
    NSUInteger dayIntervalsAssigned = 0;

    NSUInteger nightIntervalsAvailable = 0;
    NSUInteger nightIntervalsAssigned = 0;
    
    ;
    for(int i = 0; i <self.person.assignmentsArray.count; i++){
        
        NSUInteger intervalStatus = [self.person.assignmentsArray[i] unsignedIntegerValue];
        if(intervalStatus != 0){
            Interval *interval = self.schedule.intervalDataByOverallRow[i];
            if(intervalStatus == 2){
                if(interval.night){
                    nightIntervalsAssigned++;
                    nightIntervalsAvailable++;
                }else{
                    dayIntervalsAssigned++;
                    dayIntervalsAvailable++;
                }
            }
            else if(intervalStatus == 1){
                if(interval.night){
                    nightIntervalsAvailable++;

                }else{
                    dayIntervalsAvailable++;

                }
                
            }
            
        }
    }
    
    //NSLog(@"Day Intervals Assigned: %d \nDay Intervals Available: %d \nNight Intervals Assigned %d \nNight Intervals Available: %d \nTotal Intervals Assigned:%d \nTotal Intervals Available: %d", dayIntervalsAssigned, dayIntervalsAvailable, nightIntervalsAssigned, nightIntervalsAvailable,dayIntervalsAssigned+nightIntervalsAssigned, dayIntervalsAvailable+nightIntervalsAvailable );
    //NSLog(@"Total Intervals Assigned:%d \nTotal Intervals Available: %d", dayIntervalsAssigned+nightIntervalsAssigned, dayIntervalsAvailable+nightIntervalsAvailable );

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
