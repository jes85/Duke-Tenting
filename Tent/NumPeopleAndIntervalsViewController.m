//
//  NumPeopleAndIntervalsViewController.m
//  Tent
//
//  Created by Shrek on 8/6/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "NumPeopleAndIntervalsViewController.h"
//#import "HomeBaseTableViewController.h"
#import "MySchedulesTableViewController.h"
#import "Schedule.h"

@interface NumPeopleAndIntervalsViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *numPeoplePicker;

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;

- (IBAction)startDatePickerValueChanged:(id)sender;

- (IBAction)endDatePickerValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;




@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic) NSUInteger numPeople;
@end

@implementation NumPeopleAndIntervalsViewController

#pragma mark - data source

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}

#pragma mark - delegate
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 100.0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger numPeople = row+1;
    NSString *rowTitle =[NSString stringWithFormat:@"%ld people", (long)numPeople];
    

    return rowTitle;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.numPeople = row+1;
}


#pragma mark - Date Picker Actions
-(IBAction)startDatePickerValueChanged:(id)sender{
    NSLog(@"Start date: %@", self.startDatePicker.date);
}

- (IBAction)endDatePickerValueChanged:(id)sender {
    NSLog(@"End date: %@", self.endDatePicker.date);
}

#pragma mark - view-controller lifecycle
-(void)viewDidLoad
{
    self.numPeoplePicker.delegate = self;
    self.numPeoplePicker.dataSource = self;
    
    //self.startDatePicker.minimumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:0]; //round this to an hour
    //self.endDatePicker.minimumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:0]; //round this to an hour
    self.startDatePicker.minuteInterval = 15;
    self.endDatePicker.minuteInterval = 15;
    
    //NSLog("%@", self.startDatePicker.date);
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
  /*  if([[segue destinationViewController] isKindOfClass: [HomeBaseTableViewController class]]){
        HomeBaseTableViewController *hbtvc = [segue destinationViewController];
        double time = [self.endDatePicker.date timeIntervalSinceDate:self.startDatePicker.date];
        NSUInteger numHourIntervals = (NSUInteger)time/3600;
        hbtvc.numPeople = self.numPeople;
        hbtvc.numHourIntervals = numHourIntervals;
        hbtvc.startDate = self.startDatePicker.date;
        hbtvc.endDate = self.endDatePicker.date;
        

        
    }*/
    if([[segue destinationViewController] isKindOfClass: [MySchedulesTableViewController class]]){
        
        double time = [self.endDatePicker.date timeIntervalSinceDate:self.startDatePicker.date];
        NSUInteger numHourIntervals = (NSUInteger)time/3600;
        Schedule *schedule = [[Schedule alloc]initWithNumPeople:self.numPeople numHourIntervals:numHourIntervals startDate:self.startDatePicker.date endDate:self.endDatePicker.date];
        MySchedulesTableViewController *mstvc = [segue destinationViewController];
        [mstvc.schedules addObject: schedule];
    }

}



@end
