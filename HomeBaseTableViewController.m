//
//  HomeBaseTableViewController.m
//  Tent
//
//  Created by Shrek on 7/30/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "HomeBaseTableViewController.h"
#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalsTableViewController.h"
#import "Schedule.h"
#import "Interval.h"
#import "GenerateScheduleViewController.h"


#define kPersonClassName    @"Person"
#define kScheduleClassName  @"Schedule"

#define kSchedulePropertyName                   @"name"
#define kSchedulePropertyStartDate              @"startDate"
#define kSchedulePropertyEndDate                @"endDate"
#define kSchedulePropertyAvailabilitiesSchedule @"availabilitiesSchedule"
#define kSchedulePropertyAssignmentsSchedule    @"assignmentsSchedule"
#define kSchedulePropertyNumHourIntervals       @"numHourIntervals"
#define kSchedulePropertyPrivacy                @"privacy"
#define kSchedulePropertyPassword               @"password"
#define kSchedulePropertyHomeGameIndex          @"homeGameIndex"


#define kPrivacyValuePrivate                    @"private"
#define kPrivacyValuePublic                     @"public"

#define kUserPropertySchedulesList              @"schedulesList"

@interface HomeBaseTableViewController () <GenerateScheduleViewControllerDelegate>

//maybe change these to properties of schedule
@property (nonatomic) NSMutableArray *personsArray; //Person[]

@property (nonatomic) NSMutableArray *availabilitiesSchedule;
@property (nonatomic) NSMutableArray *assignmentsSchedule;


@end




@implementation HomeBaseTableViewController

#pragma mark - Property setup

-(NSMutableArray *)personsArray{
    if(!_personsArray)_personsArray = [[NSMutableArray alloc]init];
    return _personsArray;
}

-(NSMutableArray *)availabilitiesSchedule
{
    if(!_availabilitiesSchedule)_availabilitiesSchedule = [[NSMutableArray alloc]init];
    
    return _availabilitiesSchedule;
}



-(void)createPeopleArray
{
        //at creation of schedule, have them enter number of people and number of intervals
        //let there be a button to add/take out people which changes this
        
        
        // Declare peopleArray and availabilitiesSchedule
        NSMutableArray *peopleArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfAvailabilityArrays =[[NSMutableArray alloc]init];//availabilitiesSchedule
        NSMutableArray *arrayOfAssignmentArrays =[[NSMutableArray alloc]init];//assignmentsSchedule
        
        
        for(int p = 0;p<self.schedule.numPeople;p++){
            NSString *name = [NSString stringWithFormat:@"Person %d", p];
            Person *person = [[Person alloc]initWithName:name index:p numIntervals:self.schedule.numHourIntervals scheduleName:self.schedule.name];
            
            //create person's availability array and add to availabilitites schedule
            [peopleArray addObject:person];
            [arrayOfAvailabilityArrays addObject:person.availabilitiesArray];
            [arrayOfAssignmentArrays addObject:person.assignmentsArray];
            
            //save person's availabilitity array to Parse
            PFObject *personObject = [PFObject objectWithClassName:@"Person"];
            personObject[@"name"] = person.name;
            personObject[@"index"] = [NSNumber numberWithInteger:person.indexOfPerson];
            personObject[@"availabilitiesArray"] = person.availabilitiesArray;
            personObject[@"assignmentsArray"] = person.assignmentsArray;
            [personObject saveInBackground];
        }
        
        //save availabilities schedule to Parse
        PFObject *schedule= [PFObject objectWithClassName:@"Schedule"];
        schedule[@"availabilitiesSchedule"]= arrayOfAvailabilityArrays;
        schedule[@"assignmentsSchedule"]= arrayOfAssignmentArrays;
        [schedule saveInBackground];
    
    
    self.availabilitiesSchedule = arrayOfAvailabilityArrays;
    self.assignmentsSchedule = arrayOfAssignmentArrays;
    self.personsArray = peopleArray;
    
}



#pragma mark - view controller lifecycle

-(void)viewDidLoad
{
    
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Data"];
    [refresh addTarget:self action:@selector(updateAllInformation) forControlEvents:UIControlEventValueChanged];

    self.refreshControl = refresh;
    
    
    [self updatePersonsForSchedule];


}



-(void)viewWillAppear:(BOOL)animated

{
    
    [super viewWillAppear:animated];
    //[self updateInformation]; //moved this to first load (viewDidLoad) and refreshes
    
    
}

-(void)stopRefresh
{
    [self.refreshControl endRefreshing];
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
            //[self createPeopleArray];
            //[self createIntervalArray];
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
                             if (![interval.assignedPersons containsObject:person])
                             {
                                 [interval.assignedPersons addObject:person];
                                 //minor optimization:
                                 //[interval.availablePersons addObject:person];
                                 //then make next if an else if
                             }
                         }

                         if(![interval.availablePersons containsObject:person]){
                             [interval.availablePersons addObject:person];//or change to person.name
                         }
                    }
                }
                
                
                
                
            }
            //NSLog(@"Interval Array: %@", self.intervalArray);
            //NSLog(@"Persons Array: %@", self.personsArray);
            
            
            
        }
    }];

}
-(void)updateSchedule
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    
     PFQuery *query = [PFQuery queryWithClassName:@"Schedule"];
     [query whereKey:@"name" equalTo:self.schedule.name];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject *schedule, NSError *error) {
     if(!schedule){
     NSLog(@"Find failed");
     }else{
     NSLog(@"Find schedule for update succeeded");
     
         NSString *name = schedule[kSchedulePropertyName];
         NSMutableArray *availabilitiesSchedule = schedule[kSchedulePropertyAvailabilitiesSchedule];
         NSMutableArray *assignmentsSchedule = schedule[kSchedulePropertyAssignmentsSchedule];
         NSDate *startDate = schedule[kSchedulePropertyStartDate];
         NSDate *endDate = schedule[kSchedulePropertyEndDate];
         NSUInteger numHourIntervals = [schedule[kSchedulePropertyNumHourIntervals ] integerValue];
         NSString *privacy = schedule[kSchedulePropertyPrivacy];
         NSString *password = schedule[kSchedulePropertyPassword];
         NSUInteger homeGameIndex = [schedule[kSchedulePropertyHomeGameIndex] integerValue];
         
         Schedule *schedule = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex] ;
     
         self.schedule=schedule;
     
     
     }
     }];
    

}

- (void)updateAllInformation
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self updateSchedule];
    [self updatePersonsForSchedule];
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
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
   
    return 4;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if([[segue destinationViewController] isKindOfClass:[PickPersonTableViewController class]]){
        
        PickPersonTableViewController *pptvc = [segue destinationViewController];
        //maybe make personsArray a property of schedule.m? - probably not
        pptvc.people = self.personsArray;
        
        pptvc.schedule = self.schedule;
           }
    else if([[segue destinationViewController] isKindOfClass:[IntervalsTableViewController class]]){
        
        IntervalsTableViewController *itvc = [segue destinationViewController];
        itvc.intervalArray = self.schedule.intervalArray;
        itvc.hourIntervalsDisplayArray = self.schedule.hourIntervalsDisplayArray;
        
        //NSLog(@"intervalArray %@", self.intervalArray);
    }
    else if([[segue destinationViewController] isKindOfClass:[GenerateScheduleViewController class]]){
        
       GenerateScheduleViewController *gsvc = [segue destinationViewController];
        gsvc.schedule = self.schedule;
        gsvc.delegate = self;
        
        //NSLog(@"intervalArray %@", self.intervalArray);
    }

}
-(void)updatePersonsArrayOffline
{
    for(Person *person in self.personsArray){
        person.assignmentsArray = self.schedule.assignmentsSchedule[person.indexOfPerson];
    }
}

-(void)generateScheduleViewControllerDidGenerateSchedule:(GenerateScheduleViewController *)controller{
    NSLog(@"didGenerateSchedule");
    [self updatePersonsArrayOffline];
    //[self updatePersonsForSchedule];//update interval array without accessing internet
    //[self updateInformation];
}

@end
