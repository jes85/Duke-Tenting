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
#import "MyScheduleViewController.h"
#import "AdminToolsViewController.h"
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
    NSString *personName;
    if(person.user) {
        personName = [person.user objectForKey:kUserPropertyFullName];
    }else{
        personName = person.offlineName;
    }
    
    cell.textLabel.text = personName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Person *person = self.schedule.personsArray[indexPath.row];
    if ([person.user.objectId isEqual: [[PFUser currentUser] objectId]]) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Remove person on Parse
        Person *person = self.schedule.personsArray[indexPath.row];
        [PickPersonTableViewController deletePersons:@[person] fromParseSchedule:self.schedule.parseObjectID completion:^{
            
            //Update UI
            [self.schedule.personsArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }];
    }
}

+(void)deletePersons:(NSArray *)persons fromParseSchedule:(NSString *)scheduleId completion:(void(^)(void))callback
{
    NSMutableArray *userIds = [[NSMutableArray alloc]initWithCapacity:persons.count];
    NSMutableArray *parsePersons = [[NSMutableArray alloc]initWithCapacity:persons.count];
    for(Person *person in persons){
        if(person.user){
            [userIds addObject:person.user.objectId];
        }
        [parsePersons addObject:[PFObject objectWithoutDataWithClassName:kPersonClassName objectId:person.parseObjectID]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:kGroupScheduleClassName];
    [query getObjectInBackgroundWithId:scheduleId block:^(PFObject *parseSchedule, NSError *error) {
        if(!error){
            [parseSchedule removeObjectsInArray:parsePersons forKey:kGroupSchedulePropertyPersonsInGroup];
            [parseSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    /* this didn't work because don't have access to edit a different user's properties
                    PFQuery *query = [PFUser query];
                    [query whereKey:kParsePropertyObjectId containedIn:userIds];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        for(PFObject *user in objects){
                            PFRelation *relation = [user relationForKey:kUserPropertyGroupSchedules];
                            [relation removeObject:[PFObject objectWithoutDataWithClassName:kGroupScheduleClassName objectId:scheduleId]];
                        }
                        [PFObject saveAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                            if(succeeded){
                     
                            }
                        }];
                    }];
                     */
                    [PFObject deleteAllInBackground:parsePersons];
                    callback();

                }
            }];
        }
    }];
}

#pragma mark - Load data
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleChanged:) name:@"ScheduleChanged" object:nil];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}
-(void)scheduleChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    Schedule *schedule = userInfo[@"schedule"];
    [self updateLocalSchedule:schedule];
    
}
-(void)updateLocalSchedule: (Schedule *)updatedSchedule
{
    self.schedule = updatedSchedule;
    [self.tableView reloadData];
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

-(IBAction)addPerson:(UIStoryboardSegue *)segue
{
    Person *newPerson = [[Person alloc]initWithUser:nil  numIntervals:self.schedule.numIntervals];
    newPerson.offlineName = self.addPersonName; //TODO: make sure to deal with this case when displaying names and saving personArrays
    
    // Update person and schedule to parse
    PFObject *personObject = [PFObject objectWithClassName:kPersonClassName];
    personObject[kPersonPropertyAssignmentsArray] = newPerson.assignmentsArray;
    //personObject[kPersonPropertyAssociatedUser] = [NSNull null]; //set as undefined
    //personObject[kPersonPropertyIndex] = [NSNumber numberWithInteger: self.schedule.personsArray.count]; //TODO: change this to only update person index in beforesave in parse cloud code
    personObject[kPersonPropertyOfflineName] = newPerson.offlineName;
    
    [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        //query for schedule and update
        PFQuery *query = [PFQuery queryWithClassName:kGroupScheduleClassName];
        [query getObjectInBackgroundWithId:self.schedule.parseObjectID block:^(PFObject *parseSchedule, NSError *error) {
            if(!error){
                NSLog(@"Saved new person object to parse");
                
                NSMutableArray *personsArray = (NSMutableArray *)parseSchedule[kGroupSchedulePropertyPersonsInGroup];
                [personsArray addObject:personObject];
                parseSchedule[kGroupSchedulePropertyPersonsInGroup] = (NSArray *)personsArray;
                
                [parseSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        NSLog(@"Saved schedule to join to parse");
                        // Update person and schedule on current iphone (offline)

                        [self.schedule.personsArray addObject:newPerson];
                        self.addPersonName = nil;
                        [self.tableView reloadData];
                    }
                }];

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
            //if([segue.identifier isEqualToString:@"Person To Hour Interval"]){
                
                if([segue.destinationViewController  isKindOfClass:[MyScheduleViewController class]]){
                    
                    Person *person = self.schedule.personsArray[indexPath.row];
                    
                    MyScheduleViewController *msvc = [segue destinationViewController];
                    msvc.currentPerson = person; //does it violate MVC for them to be connected like this?
                    msvc.schedule = self.schedule;
                    
                    msvc.navigationItem.title = person.user? [person.user objectForKey:kUserPropertyFullName] : person.offlineName;
                }
            
        }
    }else{
        NSLog(@"Bar button add");
    }
}








@end
