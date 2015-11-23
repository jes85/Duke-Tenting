//
//  PickPersonTableViewController.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "PickPersonTableViewController.h"
#import "EnterScheduleTableViewController.h"
#import "Person.h"
#import "Schedule.h"
#import <Parse/Parse.h>
#import "Interval.h"
#import "Constants.h"
#import "MySchedulesTableViewController.h"
#import "MyScheduleContainerViewController.h"
#import "MyScheduleTableViewController.h"

@interface PickPersonTableViewController ()

@end

@implementation PickPersonTableViewController


#pragma mark - Properties - Lazy Instantiation


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    // Return the number of rows in the section.
    return [self.schedule.personsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Person *person = self.schedule.personsArray[indexPath.row];
    NSString *personName = [person.user objectForKey:kUserPropertyFullName];
    
    cell.textLabel.text = personName;
    
    return cell;
}


#pragma mark - Load data
-(void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
    if(!self.personsArray){
        [self updatePersonsForSchedule];
    }
    if(!self.schedule){
        [self updateSchedule];
    }
     */
    /*
    [self updatePersonsForSchedule];
    [self updateSchedule];
    */
}




#pragma mark - Add Person
//TODO: implement add offline person
/*
-(IBAction)addPerson:(UIStoryboardSegue *)segue
{
    // Update person and schedule on current iphone (offline)
    Person *newPerson = [[Person alloc]initWithName:self.addPersonName index:[self.schedule.personsArray count] numIntervals:self.schedule.numHourIntervals scheduleName:self.schedule.name];
    
    [self.schedule.personsArray addObject:newPerson];
    
    self.addPersonName = nil;
    
    [self.schedule.availabilitiesSchedule addObject:newPerson.availabilitiesArray];
    [self.schedule.assignmentsSchedule addObject:newPerson.assignmentsArray];
    self.schedule.numPeople++;
    [self.tableView reloadData];
    
    // Update person and schedule online
    PFObject *personObject = [PFObject objectWithClassName:kPersonClassName];
    personObject[kPersonPropertyName] = newPerson.name;
    personObject[kPersonPropertyIndex] = [NSNumber numberWithInteger:newPerson.indexOfPerson];
    personObject[kPersonPropertyAvailabilitiesArray] = newPerson.availabilitiesArray;
    personObject[kPersonPropertyAssignmentsArray] = newPerson.assignmentsArray;
    
    personObject[@"scheduleName"] = self.schedule.name;
    [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
    //query for schedule and update
    PFQuery *query = [PFQuery queryWithClassName:kScheduleClassName];
    
    [query whereKey:kPersonPropertyName equalTo:self.schedule.name];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseSchedule, NSError *error) {
        if(!parseSchedule){
            NSLog(@"Error retrieving schedule from Parse");
        }else {
            NSLog(@"Find succeeded to add new person to schedule's 2d arrays");
            NSMutableArray *availabilitiesSchedule =  parseSchedule[kSchedulePropertyAvailabilitiesSchedule];
            [availabilitiesSchedule addObject:newPerson.availabilitiesArray];
          
            parseSchedule[kSchedulePropertyAvailabilitiesSchedule]= availabilitiesSchedule;
           
            
            NSMutableArray *assignmentsSchedule = parseSchedule[kSchedulePropertyAssignmentsSchedule];
            [assignmentsSchedule addObject:newPerson.assignmentsArray];
            parseSchedule[kSchedulePropertyAssignmentsSchedule]= assignmentsSchedule;
            
            
            PFRelation *relation = [parseSchedule relationForKey:kSchedulePropertyPersonsList];
            [relation addObject:personObject];
            
            [parseSchedule saveInBackground];
           
            
        }
    }];
    }];
    
   
    
    

}
 */
-(IBAction)cancelAddPerson:(UIStoryboardSegue *)segue
{
    
}

-(IBAction)editAvailabilitiesReturn:(UIStoryboardSegue *)segue
{
    
}
#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    //Check id using introspection
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if(indexPath){
            //More checking
            //if([segue.identifier isEqualToString:@"Person To Hour Interval"]){
                
                if([segue.destinationViewController  isKindOfClass:[MyScheduleTableViewController class]]){
                    
                    Person *person = self.schedule.personsArray[indexPath.row];
                    
                    MyScheduleTableViewController *mstvc = [segue destinationViewController];
                    mstvc.currentPerson = person; //does it violate MVC for them to be connected like this?
                    mstvc.schedule = self.schedule;
                    
                    mstvc.navigationItem.title = [person.user objectForKey:kUserPropertyFullName];
                }
            
        }
    }else{
        NSLog(@"Bar button add");
    }
}








@end
