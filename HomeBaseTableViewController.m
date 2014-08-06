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
@interface HomeBaseTableViewController ()

@property (nonatomic) NSMutableArray *personsArray; //Person[]
@property (nonatomic) NSMutableArray *intervalArray; //Interval[]
@property (nonatomic) NSMutableArray *availabilitiesSchedule;
@property (nonatomic) NSMutableArray *assignmentsSchedule;
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


-(void)createPeopleArray
{
        //at creation of schedule, have them enter number of people and number of intervals
        //let there be a button to add/take out people which changes this
        
        
        // Declare peopleArray and availabilitiesSchedule
        NSMutableArray *peopleArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfAvailabilityArrays =[[NSMutableArray alloc]init];//availabilitiesSchedule
        NSMutableArray *arrayOfAssignmentArrays =[[NSMutableArray alloc]init];//assignmentsSchedule
        
        
        for(int p = 0;p<[Schedule testNumPeople];p++){
            NSString *name = [NSString stringWithFormat:@"Person %d", p];
            Person *person = [[Person alloc]initWithName:name index:p numIntervals:[Schedule testNumIntervals]];
            
            //create person's availability array and add to availabilitites schedule
            [peopleArray addObject:person];
            [arrayOfAvailabilityArrays addObject:person.availabilitiesArray];
            [arrayOfAssignmentArrays addObject:person.assignmentsArray];
            
            //save person's availabilitity array to Parse
            PFObject *personObject = [PFObject objectWithClassName:@"Person"];
            personObject[@"name"] = person.name;
            personObject[@"index"] = [NSNumber numberWithInt:person.indexOfPerson];
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
    
    
    for(int i = 0;i<[Schedule testNumIntervals];i++){
        Interval *interval = [[Interval alloc]init];
        [intervalArray addObject:interval];
    }
    self.intervalArray = intervalArray;
}
#pragma mark - view controller lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(updateInformation) forControlEvents:UIControlEventValueChanged];

    self.refreshControl = refresh;
    
    
    [self updateInformation];


}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self updateInformation]; //move this to first load (viewDidLoad) and refreshes
   

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
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!objects){
            NSLog(@"Find failed");
        }else if ([objects count]<1){
            NSLog(@"No objects in Parse");
            [self createPeopleArray];
            [self createIntervalArray];
        }
        else{
            NSLog(@"Find succeeded %d", [objects count]);
            //self.personsArray = [[NSMutableArray alloc]initWithCapacity:[Schedule testNumPeople]]; //take this out later
           // NSLog(@"personsArray: %@", self.personsArray);
            [self createIntervalArray];
            
            
            for(PFObject *object in objects){
                
                // Update personsArray
                NSString *name = object[@"name"];
                NSUInteger index = [object[@"index"] intValue];
                NSMutableArray *availableArray = object[@"availabilitiesArray"];
                NSMutableArray *assignmentsArray = object[@"assignmentsArray"];
                
                Person *person = [[Person alloc]initWithName:name index:index availabilitiesArray:availableArray assignmentsArray:assignmentsArray];
                
                
                //Fix this to prevent adding duplicates. maybe clear array and readd (but i don't want to do this every time if I don't have to)
                if(![self.personsArray containsObject:person]){
                    [self.personsArray addObject:person];
                }
                
                //self.personsArray[person.indexOfPerson] = person;
                //[self.personsArray removeObjectAtIndex:person.indexOfPerson];
                //[self.personsArray insertObject:person atIndex:person.indexOfPerson];
                
                // Update intervalsArray (change it later to save to Parse?)
                
                for(int i = 0; i<[availableArray count]; i++){
                    if([availableArray[i] isEqual:@1]){
                        Interval *interval = (Interval *)self.intervalArray[i];
                        
                        if(![interval.availablePersons containsObject:person]){
                            [interval.availablePersons addObject:person];//person.name
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
    return 3;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if([[segue destinationViewController] isKindOfClass:[PickPersonTableViewController class]]){
        
        PickPersonTableViewController *pptvc = [segue destinationViewController];
        pptvc.people = self.personsArray;
        
        //NSLog(@"array: %@", self.personsArray);
    }
    else if([[segue destinationViewController] isKindOfClass:[IntervalsTableViewController class]]){
        
        IntervalsTableViewController *itvc = [segue destinationViewController];
        itvc.intervalArray = self.intervalArray;
        
        //NSLog(@"intervalArray %@", self.intervalArray);
    }
}


@end
