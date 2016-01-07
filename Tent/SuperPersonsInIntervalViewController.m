//
//  SuperPersonsInIntervalViewController.m
//  Tent
//
//  Created by Jeremy on 1/2/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import "SuperPersonsInIntervalViewController.h"
#import "Person.h"
#import "Constants.h"

@interface SuperPersonsInIntervalViewController ()

@end

@implementation SuperPersonsInIntervalViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*
    if(self.displayCurrent == NO) {
        self.dateTimeLabel.text = self.dateTimeText;
    }
     */
}
/*
 only valid if schedule has started and is not over. returns -1 for invalid
 */
+(NSInteger)findCurrentTimeIntervalIndexForSchedule:(Schedule *)schedule
{
    if([schedule.startDate timeIntervalSinceNow] > 0 | [schedule.endDate timeIntervalSinceNow] < 0){
        return -1; //method not valid if schedule hasn't started yet or is over
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /*
    //TODO: maybe move this to another method
    if(self.displayCurrent==YES){
        [self updatePersonsArraysForCurrentTimeInterval];
    }else{
        self.dateTimeLabel.text = self.dateTimeText; //why doesn't this work in view did load?
        
    }
     */
    // Return the number of sections.
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section==0){
        if([self.interval.assignedPersons count]<1) return 1;
        return [self.interval.assignedPersons count];
    }
    if(section==1){
        if([self.interval.availablePersons count]<1) return 1;
        return [self.interval.availablePersons count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    if(section == 0)
        return [NSString stringWithFormat:@"Assigned (%lu/%lu)", (unsigned long)self.interval.assignedPersons.count, self.interval.requiredPersons];
    if(section == 1)
        return [NSString stringWithFormat:@"Available (%lu/%lu)", (unsigned long)self.interval.availablePersons.count, self.interval.requiredPersons];
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    
    //Assigned Persons
    if(indexPath.section == 0){
        
        // Display NONE if no one is assigned
        if([self.interval.assignedPersons count]<1) {
            cell.textLabel.text = @"None";
            return cell;
        }
        
        
        // Display person's name
        Person *person = self.interval.assignedPersons[indexPath.row];
        cell.textLabel.text = person.user ? [person.user objectForKey:kUserPropertyFullName] : person.offlineName;
    }
    
    
    // Available Persons
    if(indexPath.section == 1){
        
        // Display NONE if no one is available
        if([self.interval.availablePersons count]<1) {
            cell.textLabel.text = @"None";
            return cell;
        }
        
        // Display person's name
        Person *person = self.interval.availablePersons[indexPath.row];
        cell.textLabel.text = person.user ? [person.user objectForKey:kUserPropertyFullName] : person.offlineName;
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