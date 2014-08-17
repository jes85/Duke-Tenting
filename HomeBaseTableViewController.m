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
@interface HomeBaseTableViewController () <GenerateScheduleViewControllerDelegate>

//maybe change these to properties of schedule
@property (nonatomic) NSMutableArray *personsArray; //Person[]
@property (nonatomic) NSMutableArray *intervalArray; //Interval[]
@property (nonatomic) NSMutableArray *availabilitiesSchedule;
@property (nonatomic) NSMutableArray *assignmentsSchedule;

@property (nonatomic) NSMutableArray *hourIntervalsDisplayArray;
@end




@implementation HomeBaseTableViewController

#pragma mark - Property setup

-(NSMutableArray *)personsArray{
    if(!_personsArray)_personsArray = [[NSMutableArray alloc]init];
    return _personsArray;
}
-(NSMutableArray *)intervalArray
{
    if(!_intervalArray)_intervalArray = [[NSMutableArray alloc]init];
    return _intervalArray;
}
-(NSMutableArray *)availabilitiesSchedule
{
    if(!_availabilitiesSchedule)_availabilitiesSchedule = [[NSMutableArray alloc]init];
    
    return _availabilitiesSchedule;
}

-(NSMutableArray *)hourIntervalsDisplayArray
{
    if(!_hourIntervalsDisplayArray)_hourIntervalsDisplayArray = [[NSMutableArray alloc]init];
    return _hourIntervalsDisplayArray;
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
            Person *person = [[Person alloc]initWithName:name index:p numIntervals:[Schedule testNumIntervals] scheduleName:self.schedule.name];
            
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
-(void)createIntervalArray
{
    NSMutableArray *intervalArray = [[NSMutableArray alloc]init];
    NSLog(@"%lu", (unsigned long)self.schedule.numHourIntervals);
    for(int i = 0;i<self.schedule.numHourIntervals;i++){
        Interval *interval = [[Interval alloc]init];
        [intervalArray addObject:interval];
    }
    self.intervalArray = intervalArray;
}

-(void)createIntervalDisplayArray
{
    NSDate *beginningHourDate = [self.schedule.startDate copy];
    NSDate *endHourDate = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:beginningHourDate];
    
    
    
    for(int i = 0; i<self.schedule.numHourIntervals;i++){
       // NSLog(@"Test %d", self.schedule.numHourIntervals);
        NSString *beginningHourString = [NSDateFormatter localizedStringFromDate:beginningHourDate dateStyle:0 timeStyle:NSDateFormatterShortStyle];
         NSString *endHourString = [NSDateFormatter localizedStringFromDate:endHourDate dateStyle:0 timeStyle:NSDateFormatterShortStyle];
        NSString *hourInterval = [NSString stringWithFormat:@"%@ - %@", beginningHourString, endHourString];
        [self.hourIntervalsDisplayArray addObject:hourInterval];
        beginningHourDate = endHourDate;
        endHourDate = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:beginningHourDate];
        //NSLog(@"%@", hourInterval);
       
    }
    

    NSLog(@"%@", self.hourIntervalsDisplayArray);

}
#pragma mark - view controller lifecycle

-(void)viewDidLoad
{
    
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Data"];
    [refresh addTarget:self action:@selector(updateInformation) forControlEvents:UIControlEventValueChanged];

    self.refreshControl = refresh;
    
    
    [self updateInformation];


}



-(void)viewWillAppear:(BOOL)animated

{
    
    [super viewWillAppear:animated];
    //[self updateInformation]; //moved this to first load (viewDidLoad) and refreshes
    
    //testing
    if(!_hourIntervalsDisplayArray)[self createIntervalDisplayArray];
    if(!_intervalArray)[self createIntervalArray];
    
}

-(void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)updateInformation
{
    self.personsArray = nil;
    self.intervalArray = nil;
    // Get person objects from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query whereKey:@"scheduleName" equalTo:self.schedule.name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!objects){
            NSLog(@"Find failed");
        }else if ([objects count]<1){
            NSLog(@"No objects in Parse");
            //[self createPeopleArray];
            //[self createIntervalArray];
        }
        else{
            NSLog(@"Find succeeded %lu", (unsigned long)[objects count]);
            //self.personsArray = [[NSMutableArray alloc]initWithCapacity:[Schedule testNumPeople]]; //take this out later
           // NSLog(@"personsArray: %@", self.personsArray);
            [self createIntervalArray];
            
            
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
                
                for(int i = 0; i<[availabilitiesArray count]; i++){
                    if([availabilitiesArray[i] isEqual:@1]){
                        Interval *interval = (Interval *)self.intervalArray[i];
                        
                        if(![interval.availablePersons containsObject:person]){
                            [interval.availablePersons addObject:person];//or change to person.name
                        }
                        if([assignmentsArray[i] isEqual:@1]){
                            if (![interval.assignedPersons containsObject:person])
                            {
                                [interval.assignedPersons addObject:person];
                            }
                        }
                    }
                }
                
            }
            //NSLog(@"Interval Array: %@", self.intervalArray);
            //NSLog(@"Persons Array: %@", self.personsArray);
            
            
          [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
        }
    }];
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
        //maybe only communicate schedule data
        pptvc.people = self.personsArray;
        pptvc.numIntervals = self.schedule.numHourIntervals;
        pptvc.hourIntervalsDisplayArray = self.hourIntervalsDisplayArray;
        pptvc.schedule = self.schedule;
        pptvc.intervalArray = self.intervalArray;
        //NSLog(@"array: %@", self.personsArray);
    }
    else if([[segue destinationViewController] isKindOfClass:[IntervalsTableViewController class]]){
        
        IntervalsTableViewController *itvc = [segue destinationViewController];
        itvc.intervalArray = self.intervalArray;
        itvc.hourIntervalsDisplayArray = self.hourIntervalsDisplayArray;
        
        //NSLog(@"intervalArray %@", self.intervalArray);
    }
    else if([[segue destinationViewController] isKindOfClass:[GenerateScheduleViewController class]]){
        
       GenerateScheduleViewController *gsvc = [segue destinationViewController];
        gsvc.delegate = self;
        
        //NSLog(@"intervalArray %@", self.intervalArray);
    }

}

-(void)generateScheduleViewControllerDidGenerateSchedule:(GenerateScheduleViewController *)controller{
    NSLog(@"didGenerateSchedule");
    [self updateInformation];
}

@end
