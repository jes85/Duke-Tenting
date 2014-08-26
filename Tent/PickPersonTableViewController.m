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


@interface PickPersonTableViewController ()

@end

@implementation PickPersonTableViewController

@synthesize people = _people;

- (void)setPeople:(NSMutableArray *)people
{
    _people = people;
    //[self.tableView reloadData];
}
- (NSMutableArray *)people
{
    if(!_people)_people = [[NSMutableArray alloc]init];
    return _people;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    // Return the number of rows in the section.
    NSLog(@"Self.people: %lu",(unsigned long)[self.people count]);
    return [self.people count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Person *person = self.people[indexPath.row];
    NSString *personName = person.name;
    
    cell.textLabel.text = personName;
    
    return cell;
}

#pragma mark - Add Person
-(IBAction)addPerson:(UIStoryboardSegue *)segue
{
    // Update person and schedule on current iphone (offline)
    Person *newPerson = [[Person alloc]initWithName:self.addPersonName index:[self.people count] numIntervals:self.schedule.numHourIntervals scheduleName:self.schedule.name];
    
    [self.people addObject:newPerson];
    
    self.addPersonName = nil;
    
    [self.schedule.availabilitiesSchedule addObject:newPerson.availabilitiesArray];
    [self.schedule.assignmentsSchedule addObject:newPerson.assignmentsArray];
    self.schedule.numPeople++;
    [self.tableView reloadData];
    
    // Update person and schedule online
    PFObject *personObject = [PFObject objectWithClassName:@"Person"];
    personObject[@"name"] = newPerson.name;
    personObject[@"index"] = [NSNumber numberWithInteger:newPerson.indexOfPerson];
    personObject[@"availabilitiesArray"] = newPerson.availabilitiesArray;
    personObject[@"assignmentsArray"] = newPerson.assignmentsArray;
    
    personObject[@"scheduleName"] = self.schedule.name;
    [personObject saveInBackground];
    
    //query for schedule and update
    PFQuery *query = [PFQuery queryWithClassName:@"Schedule"];
    
    [query whereKey:@"name" equalTo:self.schedule.name];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseSchedule, NSError *error) {
        if(!parseSchedule){
            NSLog(@"Error retrieving schedule from Parse");
        }else {
            NSLog(@"Find succeeded to add new person to schedule's 2d arrays");
            NSMutableArray *availabilitiesSchedule =  parseSchedule[@"availabilitiesSchedule"];
            [availabilitiesSchedule addObject:newPerson.availabilitiesArray];
          
            parseSchedule[@"availabilitiesSchedule"]= availabilitiesSchedule;
           
            
            NSMutableArray *assignmentsSchedule = parseSchedule[@"assignmentsSchedule"];
            [assignmentsSchedule addObject:newPerson.assignmentsArray];
            parseSchedule[@"assignmentsSchedule"]= assignmentsSchedule;
            
            [parseSchedule saveInBackground];
           
            
        }
    }];
    
   
    
    

}
-(IBAction)cancelAddPerson:(UIStoryboardSegue *)segue
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
            if([segue.identifier isEqualToString:@"Person To Hour Interval"]){
                
                if([segue.destinationViewController  isKindOfClass:[EnterScheduleTableViewController class]]){
                    
                    Person *person = self.people[indexPath.row];
                    
                    EnterScheduleTableViewController *estvc = [segue destinationViewController];
                    estvc.currentPerson = person; //does it violate MVC for them to be connected like this?
                    estvc.hourIntervalsDisplayArray = self.schedule.hourIntervalsDisplayArray;
                    estvc.intervalArray = self.schedule.intervalArray;
                    
                    estvc.navigationItem.title = person.name;
                }
            }
        }
    }else{
        NSLog(@"Bar button add");
    }
}





//Save data
-(IBAction)unWindToList:(UIStoryboardSegue *)segue
{
    
    //was going to update self.people, but found out that self.people[source.currentPerson.indexOfPerson] was pointing to the same object as source.currentPerson, so there is no need to update (self.people is updated when source.currentPerson is updated)
    
    //need to check how pointers work more to understand when it will point to the same object and when it will create a new space in memory with the same value as the other object
    /*
     EnterScheduleTableViewController *source = [segue sourceViewController];
     Person *person = source.currentPerson;
     if(![[self.people objectAtIndex:person.indexOfPerson] isEqual: person]){
     NSLog(@"Test Equality1");
     [self.people removeObjectAtIndex:person.indexOfPerson];
     [self.people insertObject:person atIndex:person.indexOfPerson];
     }else{
     NSLog(@"Test Equality2");
     }
     
     
     //test
     NSLog(@"Source's person: %@", person);
     NSLog(@"My person: %@", person);
     [self.people removeObjectAtIndex:person.indexOfPerson];
     [self.people insertObject:person atIndex:person.indexOfPerson];
     NSLog(@"Source's person: %@", person);
     NSLog(@"My person: %@", person);
     
     */
}





@end
