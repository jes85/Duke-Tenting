//
//  PickPersonTableViewController.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "PickPersonTableViewController.h"
#import "Person.h"
#import "Schedule.h"
#import <Parse/Parse.h>
#import "Interval.h"
#import "Constants.h"
#import "MySchedulesTableViewController.h"
#import "MyScheduleContainerViewController.h"
#import "OtherPersonScheduleViewController.h"
#import "AdminToolsViewController.h"

@interface PickPersonTableViewController ()

@end

@implementation PickPersonTableViewController

#pragma mark - View Controller Lifecycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleChanged:) name:kNotificationNameScheduleChanged object:nil];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}
-(void)scheduleChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    Schedule *schedule = userInfo[kUserInfoLocalScheduleKey];
    
    //don't think i need to update UI here since it will always call viewDidLoad for next vc, and any changes that would result in this vc needing to update UI would occur in this vc
    self.schedule = schedule;
    [self updateLocalSchedule:schedule];
    
}

 -(void)updateLocalSchedule: (Schedule *)updatedSchedule
{
     self.schedule = updatedSchedule;
     [self.tableView reloadData];
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
        [PickPersonTableViewController deletePersons:@[person.parseObjectID] fromParseSchedule:self.schedule.parseObjectID completion:^{
            
            //Update UI
            [self.schedule.personsArray removeObjectAtIndex:indexPath.row];
            [self.schedule createIntervalDataArrays];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //Notify other vcs
            NSDictionary *userInfo = @{kUserInfoLocalScheduleKey: self.schedule, kUserInfoLocalScheduleChangedPropertiesKey:@[kUserInfoLocalSchedulePropertyPersonsArray]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameScheduleChanged object:self userInfo:userInfo];
            
        }];
    }
}

+(void)deletePersons:(NSArray *)personIds fromParseSchedule:(NSString *)scheduleId completion:(void(^)(void))callback
{
    NSMutableArray *parsePersons = [[NSMutableArray alloc]initWithCapacity:personIds.count];
    for(NSString *personId in personIds){
        [parsePersons addObject:[PFObject objectWithoutDataWithClassName:kPersonClassName objectId:personId]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:kGroupScheduleClassName];
    [query getObjectInBackgroundWithId:scheduleId block:^(PFObject *parseSchedule, NSError *error) {
        if(!error){
            [parseSchedule removeObjectsInArray:parsePersons forKey:kGroupSchedulePropertyPersonsInGroup];
            [parseSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [PFObject deleteAllInBackground:parsePersons];
                    callback();

                }
            }];
        }
    }];
}



#pragma mark - Add Offline Person
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
            if(!error){ // Saved new person object to parse
                
                NSMutableArray *personsArray = (NSMutableArray *)parseSchedule[kGroupSchedulePropertyPersonsInGroup];
                [personsArray addObject:personObject];
                parseSchedule[kGroupSchedulePropertyPersonsInGroup] = (NSArray *)personsArray;
                
                [parseSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){ // Saved schedule to parse
                        
                        // Update person and schedule on current iphone (offline)
                        newPerson.scheduleIndex = self.schedule.personsArray.count;
                        newPerson.parseObjectID = personObject.objectId;
                        [self.schedule.personsArray addObject:newPerson];
                        self.addPersonName = nil;
                        [self.tableView reloadData];
                        
                        NSDictionary *userInfo = @{kUserInfoLocalScheduleKey: self.schedule, kUserInfoLocalScheduleChangedPropertiesKey:@[kUserInfoLocalSchedulePropertyOther]};//personsArray is changed but it doesn't alter other vcs' views so no need to tell them to update their UI (which is what the kUserInfo...PropertyPersonsArray is for)
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameScheduleChanged object:self userInfo:userInfo];
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
                
                if([segue.destinationViewController  isKindOfClass:[OtherPersonScheduleViewController class]]){
                    
                    Person *person = self.schedule.personsArray[indexPath.row];
                    
                    OtherPersonScheduleViewController *opsvc = [segue destinationViewController];
                    opsvc.currentPerson = person; //does it violate MVC for them to be connected like this?
                    opsvc.schedule = self.schedule;
                    
                    opsvc.navigationItem.title = person.user? [person.user objectForKey:kUserPropertyFullName] : person.offlineName;
                }
            
        }
    }else{
        // Bar button add segue
    }
}








@end
