//
//  PersonsInIntervalViewController.m
//  Tent
//
//  Created by Jeremy on 11/12/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "PersonsInIntervalViewController.h"
#import "Interval.h"
#import "Constants.h"
#import "Person.h"
@interface PersonsInIntervalViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@end

@implementation PersonsInIntervalViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if(self.displayCurrent == NO) {
        self.dateTimeLabel.text = self.dateTimeText;
    }
    NSLog(self.dateTimeLabel.text);
}

+(NSInteger)findCurrentTimeIntervalIndexForSchedule:(Schedule *)schedule
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *datedifferenceComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:schedule.startDate toDate:[NSDate date] options:0];
    
    NSInteger hours = datedifferenceComponents.hour;
    NSInteger minutes = datedifferenceComponents.minute;
    
    //TODO: calculate time interval index based on interval length setting and hours/minutes
    NSInteger index = hours;
    if(minutes < 0){ 
        index = index - 1;
    }
    
    return index;
   
    
}

-(void)updatePersonsArraysForCurrentTimeInterval
{
    NSInteger index = [PersonsInIntervalViewController findCurrentTimeIntervalIndexForSchedule:self.schedule];
    if(index < 0) {
        // display fact that schedule has not started yet
        self.dateTimeLabel.text = @"Schedule has not started yet";
        return;
    }
    Interval *interval = self.schedule.intervalDataByOverallRow[index];
    self.availablePersonsArray = interval.availablePersons;
    self.assignedPersonsArray = interval.assignedPersons;
    self.dateTimeText = interval.dateTimeString;
    self.dateTimeLabel.text = interval.dateTimeString;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //TODO: maybe move this to another method
    if(self.displayCurrent==YES){
        [self updatePersonsArraysForCurrentTimeInterval];
    }
    // Return the number of sections.

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section==0){
        if([self.assignedPersonsArray count]<1) return 1;
        return [self.assignedPersonsArray count];
    }
    if(section==1){
        if([self.availablePersonsArray count]<1) return 1;
        return [self.availablePersonsArray count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"Assigned";
    if(section == 1)
        return @"Available";
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    
    //Assigned Persons
    if(indexPath.section == 0){
        
        // Display NONE if no one is assigned
        if([self.assignedPersonsArray count]<1) {
            cell.textLabel.text = @"None";
            return cell;
        }
        
        
        // Display person's name
        Person *person = self.availablePersonsArray[indexPath.row];
        cell.textLabel.text = [person.user objectForKey:kUserPropertyFullName];
    }
    
    
    // Available Persons
    if(indexPath.section == 1){
        
        // Display NONE if no one is available
        if([self.availablePersonsArray count]<1) {
            cell.textLabel.text = @"None";
            return cell;
        }
        
        // Display person's name
        Person *person = self.availablePersonsArray[indexPath.row];
        cell.textLabel.text = [person.user objectForKey:kUserPropertyFullName];
    }
    return cell;
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
