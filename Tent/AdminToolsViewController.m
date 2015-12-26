//
//  AdminToolsViewController.m
//  Tent
//
//  Created by Jeremy on 12/24/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "AdminToolsViewController.h"
#import "Constants.h"
#import "Person.h"
#import "AlgorithmSchedule.h"
#import <Parse/Parse.h>
@interface AdminToolsViewController ()

@end

@implementation AdminToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)generateAssignmentsButtonPressed:(id)sender {
    NSString *title = @"Generate Assignments";
    NSString *message = self.schedule.assignmentsGenerated ? @"Are you sure you want to generate new schedule assignments? The previous assignments will be lost" : @"Are you sure you want to generate assignments?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self generateAssignments];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:proceedAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)clearAssignmentsButtonPressed:(id)sender {
    NSString *title = @"Clear Assignments";
    if(self.schedule.assignmentsGenerated){
        NSString *message = @"Are you sure you want to clear the schedule assignments that were generated? The availabilities data will not change.";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self clearAssignments];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:proceedAction];
        [self presentViewController:alert animated:YES completion:nil];

    }else{
        NSString *message = @"You have not generated any assignments. Press the 'Generate Assignments' button to automatically generate them.";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}
- (IBAction)clearAvailabilitiesButtonPressed:(id)sender {
    NSString *title = @"Clear Availabilities";
    NSString *message = self.schedule.assignmentsGenerated ? @"Are you sure? Both the assignments and availabilties will be deleted." : @"Are you sure?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self clearAvailabilities];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:proceedAction];
    [self presentViewController:alert animated:YES completion:nil];
        
}

-(void)generateAssignments
{
    AlgorithmSchedule *algorithmSchedule = [self createAlgorithmScheduleFromScheduleObject];
    if([algorithmSchedule checkForError]){
        //deal with error
        return;
    }
    NSMutableArray *assignments = [algorithmSchedule generateAssignments];
    [self updateScheduleWithAlgorithmScheduleAssignments:assignments];
}
-(AlgorithmSchedule *)createAlgorithmScheduleFromScheduleObject
{
    NSMutableArray *assignmentsSchedule = [[NSMutableArray alloc]init];
    for(Person *person in self.schedule.personsArray){
        [assignmentsSchedule addObject:person.assignmentsArray];
    }
    AlgorithmSchedule *algorithmSchedule = [[AlgorithmSchedule alloc]initWithStartDate:self.schedule.startDate endDate:self.schedule.endDate intervalLengthInMinutes:self.schedule.intervalLengthInMinutes assignmentsSchedule:assignmentsSchedule numIntervals:self.schedule.numIntervals];
    return algorithmSchedule;
}
-(void)updateScheduleWithAlgorithmScheduleAssignments:(NSMutableArray *)assignments
{
    //update Parse Schedule
        //update persons arrays and assignmentsGenerated
    //update local schedule
        //update persons arrays and assignmentsGenerated
    
    NSMutableArray *objectIds = [[NSMutableArray alloc]initWithCapacity:self.schedule.personsArray.count];
    for(Person *person in self.schedule.personsArray){
        [objectIds addObject:person.parseObjectID];
    }
    PFQuery *query = [PFQuery queryWithClassName:kPersonClassName];
    
    [query whereKey:@"objectId" containedIn:objectIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(PFObject *parsePerson in objects){
                parsePerson[kPersonPropertyAssignmentsArray] = assignments[[parsePerson[kPersonPropertyIndex] integerValue]];
                
            }
            [PFObject saveAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    PFQuery *scheduleQuery = [PFQuery queryWithClassName:kGroupScheduleClassName];
                    [scheduleQuery getObjectInBackgroundWithId:self.schedule.parseObjectID block:^(PFObject *object, NSError *error) {
                        object[kGroupSchedulePropertyAssignmentsGenerated] = [NSNumber numberWithBool:YES];
                        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(succeeded){
                                //TODO: update local iphone
                                
                                //Alert success message
                                [self alertSuccessWithMessage:@"Assignments were successfully generated."];
                            }
                        }];
                    }];

                }
            }];
        }
    }];
    
}
-(void)clearAssignments
{
    //update parse
    NSMutableArray *parsePersonIds = [[NSMutableArray alloc]initWithCapacity:self.schedule.personsArray.count];
    NSMutableArray *clearedAssignmentsArrays = [[NSMutableArray alloc]initWithCapacity:self.schedule.personsArray.count];
    for(int i = 0; i<self.schedule.personsArray.count;i++){
        Person *person = self.schedule.personsArray[i];
        [parsePersonIds addObject:person.parseObjectID];
        [clearedAssignmentsArrays addObject:[self clearedAssignmentsArrayFromAssignmentsArray:person.assignmentsArray]];
        
    }
    
    [self updatePersons:parsePersonIds WithNewAssignmentsArrays:clearedAssignmentsArrays];
   
   
    
}
-(NSMutableArray *)clearedAssignmentsArrayFromAssignmentsArray:(NSMutableArray *)assignmentsArray
{
    for(int i = 0; i<assignmentsArray.count;i++){
        if([assignmentsArray[i] isEqual:@2]) assignmentsArray[i] = @1;
    }
    return assignmentsArray;
}
-(void)clearAvailabilities
{
    //update parse
    NSMutableArray *parsePersonIds = [[NSMutableArray alloc]initWithCapacity:self.schedule.personsArray.count];
    NSMutableArray *clearedAssignmentsArrays = [[NSMutableArray alloc]initWithCapacity:self.schedule.personsArray.count];
    for(int i = 0; i<self.schedule.personsArray.count;i++){
        Person *person = self.schedule.personsArray[i];
        [parsePersonIds addObject:person.parseObjectID];
        [clearedAssignmentsArrays addObject:[self clearedAvailabilitiesArrayFromAssignmentsArray:person.assignmentsArray]];
        
    }
    
    [self updatePersons:parsePersonIds WithNewAssignmentsArrays:clearedAssignmentsArrays];
    
}
-(NSMutableArray *)clearedAvailabilitiesArrayFromAssignmentsArray:(NSMutableArray *)assignmentsArray
{
    for(int i = 0; i<assignmentsArray.count;i++){
        assignmentsArray[i] = @0;
    }
    return assignmentsArray;
}

-(void)updatePersons:(NSMutableArray *)parsePersonIds WithNewAssignmentsArrays:(NSMutableArray *)assignmentsArrays
{
    PFQuery *query = [PFQuery queryWithClassName:kPersonClassName];
    [query whereKey:@"objectId" containedIn:parsePersonIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(int i = 0; i<objects.count;i++){
                PFObject *parsePerson = objects[i];
                parsePerson[kPersonPropertyAssignmentsArray] = assignmentsArrays[i];
            }
            [PFObject saveAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    //update UI
                    for(int i = 0; i<self.schedule.personsArray.count;i++){
                        Person *person = self.schedule.personsArray[i];
                        person.assignmentsArray = assignmentsArrays[i];
                        
                    }
                    
                    //TODO: update local schedule object in other vcs
                    
                    //Show success alert
                    //TODO: make method return a completion handler
                    [self alertSuccessWithMessage:@"Successfully cleared schedule"];
                }
            }];
        }
    }];
}
-(void)alertSuccessWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
