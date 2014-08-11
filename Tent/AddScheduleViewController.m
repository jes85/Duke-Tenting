//
//  AddScheduleViewController.m
//  Tent
//
//  Created by Shrek on 8/9/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "AddScheduleViewController.h"
//#import "HomeBaseTableViewController.h"
#import "MySchedulesTableViewController.h"
#import "Schedule.h"

@interface AddScheduleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *enterNameTextField;
@property (nonatomic) NSUInteger numPeople;
@property (weak, nonatomic) IBOutlet UIPickerView *numPeoplePicker; //for testing only?

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
- (IBAction)startDatePickerValueChanged:(id)sender;
- (IBAction)endDatePickerValueChanged:(id)sender;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation AddScheduleViewController


#pragma mark - Done Button
-(BOOL)shouldEnableDoneButton
{
    BOOL enableDoneButton = NO;
    if(self.enterNameTextField.text!=nil && self.enterNameTextField.text.length>0)
    {
        enableDoneButton = YES;
    }
    return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note
{
    self.doneButton.enabled = [self shouldEnableDoneButton];
}
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
    NSInteger numPeople = row;
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
    
    //NSLog(@"%@", self.startDatePicker.date);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.enterNameTextField];
    self.doneButton.enabled = NO;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if(sender==self.doneButton){
        if([[segue destinationViewController] isKindOfClass: [MySchedulesTableViewController class]]){
        
            double time = [self.endDatePicker.date timeIntervalSinceDate:self.startDatePicker.date];
            NSUInteger numHourIntervals = (NSUInteger)time/3600;
            Schedule *schedule = [[Schedule alloc]initWithNumPeople:self.numPeople numHourIntervals:numHourIntervals startDate:
                                  self.startDatePicker.date endDate:self.endDatePicker.date];
            schedule.name = self.enterNameTextField.text;
            MySchedulesTableViewController *mstvc = [segue destinationViewController];
            [mstvc.schedules addObject: schedule];
            
           
        }
    }
   
}



@end

