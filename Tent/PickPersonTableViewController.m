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

@interface PickPersonTableViewController ()

@end

@implementation PickPersonTableViewController


#pragma mark - Properties - Lazy Instantiation
/*
- (NSMutableArray *)personsArray
{
    if(!_personsArray)_personsArray = [[NSMutableArray alloc]init];
    return _personsArray;
}
 */


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    // Return the number of rows in the section.
    return [self.personsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Person *person = self.personsArray[indexPath.row];
    NSString *personName = person.name;
    
    cell.textLabel.text = personName;
    
    return cell;
}


#pragma mark - Load data
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
-(void)updatePersonsForSchedule
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    self.personsArray = nil; //maybe change personsArray to be property of schedule too?
    self.schedule.intervalArray = [self.schedule createZeroedIntervalArray]; //get rid of this and just reload schedule from parse
    
    // Get person objects from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query whereKey:@"scheduleName" equalTo:self.schedule.name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!objects){
            NSLog(@"Find failed");
        }else if ([objects count]<1){
            NSLog(@"No persons for schedule %@ in Parse", self.schedule.name);
        }
        else{
            NSLog(@"Find persons for Schedule %@ succeeded %lu", self.schedule.name,(unsigned long)[objects count]);
            //self.personsArray = [[NSMutableArray alloc]initWithCapacity:[Schedule testNumPeople]]; //take this out later
            // NSLog(@"personsArray: %@", self.personsArray);
            //[self.schedule createIntervalArray];
            
            
            for(PFObject *object in objects){
                
                // Update personsArray
                NSString *name = object[@"name"];
                NSUInteger index = [object[@"index"] intValue];
                NSMutableArray *availabilitiesArray = object[@"availabilitiesArray"];
                NSMutableArray *assignmentsArray = object[@"assignmentsArray"];
                
                Person *person = [[Person alloc]initWithName:name index:index availabilitiesArray:availabilitiesArray assignmentsArray:assignmentsArray scheduleName:self.schedule.name];
                
                
                //Fix this to prevent adding duplicates. maybe clear array and readd (but i don't want to do this every time if I don't have to)
                if(![self.personsArray containsObject:person]){
                    [self.personsArray addObject:person];
                }
                
                //self.personsArray[person.indexOfPerson] = person;
                //[self.personsArray removeObjectAtIndex:person.indexOfPerson];
                //[self.personsArray insertObject:person atIndex:person.indexOfPerson];
                
                // Update intervalsArray (change it later to save to Parse?)
                //maybe move this to schedule.m
                
                for(int i = 0; i<[availabilitiesArray count]; i++){
                    if([availabilitiesArray[i] isEqual:@1]){
                        Interval *interval = (Interval *)self.schedule.intervalArray[i];
                        if([assignmentsArray[i] isEqual:@1]){
                            if (![interval.assignedPersons containsObject:person.name])
                            {
                                [interval.assignedPersons addObject:person.name];
                                //minor optimization:
                                //[interval.availablePersons addObject:person];
                                //then make next if an else if
                            }
                        }
                        
                        if(![interval.availablePersons containsObject:person.name]){
                            [interval.availablePersons addObject:person.name];//used to be array of persons, but then equality would change if person's availability or assigned array changed, and the same person would be added twice
                        }
                    }
                }
                
                
                
                
            }
            
            [self.tableView reloadData];
            
        }
    }];
    
}
//same as updateSchedule in HomeBase. Consolidate this
-(void)updateSchedule
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Schedule"];
    [query whereKey:@"name" equalTo:self.schedule.name];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseSchedule, NSError *error) {
        if(!parseSchedule){
            NSLog(@"Find failed");
        }else{
            NSLog(@"Find schedule for update succeeded");
            

            Schedule *scheduleObject = [MySchedulesTableViewController createScheduleObjectFromParseInfo:parseSchedule];
            
            self.schedule=scheduleObject;
            [self.tableView reloadData];
            
            
        }
    }];
    
    
}



#pragma mark - Add Person
-(IBAction)addPerson:(UIStoryboardSegue *)segue
{
    // Update person and schedule on current iphone (offline)
    Person *newPerson = [[Person alloc]initWithName:self.addPersonName index:[self.personsArray count] numIntervals:self.schedule.numHourIntervals scheduleName:self.schedule.name];
    
    [self.personsArray addObject:newPerson];
    
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
            if([segue.identifier isEqualToString:@"Person To Hour Interval"]){
                
                if([segue.destinationViewController  isKindOfClass:[EnterScheduleTableViewController class]]){
                    
                    Person *person = self.personsArray[indexPath.row];
                    
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








@end
