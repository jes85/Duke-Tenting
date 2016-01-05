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

@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    self.navigationItem.title = self.person.user ? [self.person.user objectForKey:kUserPropertyFullName] : self.person.offlineName;
    
    NSArray *info = [self calculateMinutesAvailableAndAssigned];
    NSUInteger minutesAvailable = [info[0] unsignedIntegerValue];
    NSUInteger minutesAssigned = [info[1] unsignedIntegerValue];

    self.minutesAvailableLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)minutesAvailable];
    self.minutesAssignedLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)minutesAssigned];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
