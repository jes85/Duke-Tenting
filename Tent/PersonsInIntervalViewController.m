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
        [self.view addSubview:self.dateTimeLabel];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.displayCurrent == NO) {
        self.dateTimeLabel.text = self.dateTimeText;
    }
}
/*
 only valid if schedule has started and is not over
 */
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
    NSInteger index = [PersonsInIntervalViewController findCurrentTimeIntervalIndexForSchedule:self.schedule];
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
    }else{
        NSString *test1 = self.dateTimeLabel.text;
        NSString *test2 = self.dateTimeText;

        self.dateTimeLabel.text = self.dateTimeText; //why doesn't this work in view did load?
        NSString *test3 = self.dateTimeLabel.text;
        NSString *test4 = self.dateTimeText;

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
        return [NSString stringWithFormat:@"Assigned (%lu/%lu)", (unsigned long)self.assignedPersonsArray.count, self.requiredPersons];
    if(section == 1)
        return [NSString stringWithFormat:@"Available (%lu/%lu)", (unsigned long)self.availablePersonsArray.count, self.requiredPersons];;
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
        cell.textLabel.text = person.user ? [person.user objectForKey:kUserPropertyFullName] : person.offlineName;
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
