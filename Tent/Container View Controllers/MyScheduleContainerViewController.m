//
//  MyScheduleContainerViewController.m
//  Tent
//
//  Created by Jeremy on 10/8/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MyScheduleContainerViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "Person.h"
#import "Interval.h"
#import "MySchedulesTableViewController.h"
#import "PickPersonTableViewController.h"
#import "IntervalsTableViewController.h"
#import "PersonsInIntervalViewController.h"
#import "MyScheduleTableViewController.h"
#import "ScheduleSettingsViewController.h"

@interface MyScheduleContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *viewGameInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelOpponent;


@end

@implementation MyScheduleContainerViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self drawBorders];
    [self updateGameLabels];
    [self updatePersonsForSchedule];
    //[self displayViewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editBarButtonItemPressed)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(settingsBarButtonItemPressed)];
    settingsButton.image = [UIImage imageNamed:@"Icon_Gear"];
    
    self.navigationItem.rightBarButtonItems = @[editButton, settingsButton];
}
-(void)editBarButtonItemPressed
{
    
}
-(void)settingsBarButtonItemPressed
{
    [self performSegueWithIdentifier:@"MyScheduleSettingsSegue" sender:self];
}
-(void)drawBorders
{
    CGFloat borderWidth = 1.0f;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(self.viewGameInfo.frame.origin.x, self.viewGameInfo.frame.size.height - borderWidth, self.viewGameInfo.frame.size.width, borderWidth);
    bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
    
    [self.viewGameInfo.layer addSublayer:bottomBorder];
    
}
-(void)updateGameLabels
{
    //self.labelScheduleName.text = self.schedule.name;
    //self.labelOpponent.text = self.schedule.opponent;
    //self.labelOpponent.text = self.schedule.opponent;
    self.labelOpponent.text = self.opponentName;
    self.labelDate.text = [[[Constants formatDate:self.schedule.endDate withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "] stringByAppendingString:[Constants formatTime:self.schedule.endDate withStyle:NSDateFormatterShortStyle]];

    self.navigationItem.title = self.schedule.name;
    
}

-(void)refreshData
{
    //update My Schedule
    //update Current People
    //update Persons
    //update time intervals
    
}

- (void) displayViewControllerForSegmentIndex: (NSInteger) index
{
    UIViewController *vc = [self viewControllerForSegmentIndex:index];
    [self addChildViewController:vc];
    vc.view.frame = [self frameForContentController];
    [self.containerView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    self.currentViewController = vc;
    
}

- (UIViewController *) viewControllerForSegmentIndex: (NSInteger)index
{
    if([self.viewControllers[index] isKindOfClass:[MyScheduleTableViewController class]] && (self.schedule.personsArray)){ //TODO: add condition that persons array is > 1 count
        
        //this gets called every time segment index is switched. should really only happen once, or once every time there's an update to current user's schedule
        MyScheduleTableViewController *mstvc = self.viewControllers[index];
        mstvc.currentPerson = self.schedule.personsArray[self.schedule.currentUserPersonIndex];
        mstvc.schedule = self.schedule;
        
    }
    
    return self.viewControllers[index];
}

-(NSArray *)viewControllers
{
    if(!_viewControllers) _viewControllers = [self instantiateViewControllers];
    return _viewControllers;
}

-(NSArray *)instantiateViewControllers
{
    NSArray *viewControllerIdentifiers = @[kChildViewControllerMe,kChildViewControllerCurrent, kChildViewControllerOthers,kChildViewControllerTimeSlots];
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:4];
    
    
    UIViewController *vc;
    for (NSString *identifier in viewControllerIdentifiers) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        [array addObject:vc];
    }
    
    return array;
}

-(CGRect)frameForContentController
{
    return self.containerView.bounds;
}

- (void)cycleFromViewController: (UIViewController*) oldVC
               toViewController: (UIViewController*) newVC {
    
    
    // Prepare the two view controllers for the change.
    [oldVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    
    if([newVC isKindOfClass:[PickPersonTableViewController class]]){
        PickPersonTableViewController *pptvc = (PickPersonTableViewController *)newVC;
        pptvc.schedule = self.schedule;
        
    }else if ([newVC isKindOfClass:[IntervalsTableViewController class]]){
        IntervalsTableViewController *itvc = (IntervalsTableViewController *)newVC;
        itvc.schedule = self.schedule;
        
    }else if([newVC isKindOfClass:[MyScheduleTableViewController class]]){
        MyScheduleTableViewController *mstvc = (MyScheduleTableViewController *)newVC;
        mstvc.schedule = self.schedule;
        
    }else if ([newVC isKindOfClass:[PersonsInIntervalViewController class]]){
        PersonsInIntervalViewController *piivc = (PersonsInIntervalViewController *)newVC;
        piivc.schedule = self.schedule;
        piivc.displayCurrent = YES;
        
    }
    
    CGRect frame = CGRectMake(-self.containerView.bounds.size.width, self.containerView.bounds.origin.y, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    newVC.view.frame = frame;

    [self transitionFromViewController:oldVC toViewController:newVC duration:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [oldVC.view removeFromSuperview];
        [self.containerView addSubview:newVC.view];

    } completion:^(BOOL finished) {
        newVC.view.frame = [self frameForContentController];
        [oldVC removeFromParentViewController];
        [newVC didMoveToParentViewController:self];
    }];
    
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    UIViewController *newVC = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    
    [self cycleFromViewController:self.currentViewController toViewController:newVC];
    
    self.currentViewController = newVC;
}






-(void)updatePersonsForSchedule
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    self.schedule.personsArray = nil; //maybe change personsArray to be property of schedule too?
    [self.schedule resetIntervalArray]; //get rid of this and just reload schedule from parse
    
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
                
                person.userObjectID = [object[kPersonPropertyUserPointer] objectId];
                
                if([person.userObjectID isEqualToString:[[PFUser currentUser] objectId]]){
                    self.schedule.currentUserPersonIndex = self.schedule.personsArray.count; //TODO: check logic
                }
                
                //Fix this to prevent adding duplicates. maybe clear array and readd (but i don't want to do this every time if I don't have to)
                if(![self.schedule.personsArray containsObject:person]){
                    [self.schedule.personsArray addObject:person];
                }
                
                //self.personsArray[person.indexOfPerson] = person;
                //[self.personsArray removeObjectAtIndex:person.indexOfPerson];
                //[self.personsArray insertObject:person atIndex:person.indexOfPerson];
                
                // Update intervalsArray (change it later to save to Parse?)
                //maybe move this to schedule.m
                
                for(int i = 0; i<[availabilitiesArray count]; i++){
                    if([availabilitiesArray[i] isEqual:@1]){
                        Interval *interval = (Interval *)self.schedule.intervalDataByOverallRow[i];
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
            
            //update table view data of child view controllers
            
        }
        [self displayViewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];

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
            //update table view data for views (or just do that in view did appear for each of them)
            
            
        }
    }];
    
    
}

-(NSDictionary *)createSettingsDictionary
{
    NSDictionary *section0 = @{
                               @"sectionHeader":@"General",
                               @"sectionData": @[
                                   @{
                                       @"title": @"Schedule Name:",
                                       @"value": self.schedule.name,
                                       },
                                   @{
                                       @"title": @"Opponent:",
                                       @"value": @"opponent",
                                       },
                                   @{
                                       @"title": @"Group Code:",
                                       @"value": self.schedule.password,
                                       
                                       }
                                   ],
                               };
    NSDictionary *section1 = @{
                               @"sectionHeader":@"Dates",
                               @"sectionData": @[
                                       @{
                                           @"title": @"Start Date:",
                                           @"value": self.schedule.startDate
                                           },
                                       @{
                                           @"title": @"End Date:",
                                           @"value": self.schedule.endDate
                                           },
                                       @{
                                           @"title": @"Game Time:",
                                           @"value": @"game time" //change to gameTime
                                           
                                           }
                                       ],
                               };
    
    return @{@0:section0, @1:section1};

}
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([[segue destinationViewController] isKindOfClass:[ScheduleSettingsViewController class]]){
         ScheduleSettingsViewController *ssvc = [segue destinationViewController];
         ssvc.settings = [self createSettingsDictionary];
     }
 }
 

@end
