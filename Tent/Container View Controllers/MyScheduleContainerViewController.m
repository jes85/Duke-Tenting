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
#import "MeScheduleViewController.h"
#import "ScheduleSettingsViewController.h"
#import "NowPersonsInIntervalViewController.h"

@interface MyScheduleContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *viewGameInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelOpponent;


@property (nonatomic) UIBarButtonItem *editButton;
@property (nonatomic) UIBarButtonItem *editPeopleButton;
@property (nonatomic) UIBarButtonItem *settingsButton;
@property (nonatomic) UIBarButtonItem *addPersonButton;


@end

@implementation MyScheduleContainerViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[[PFUser currentUser] objectId] isEqual: self.schedule.createdBy.objectId]){
        self.isCreator = true;
    }else{
        self.isCreator = false;
    }

    //[self drawBorders];
    [self updateGameLabels];
    //[self updatePersonsForSchedule];
    //[self updateSchedule];
    [self displayViewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editBarButtonItemPressed)];
    self.editButton = editButton;
    UIBarButtonItem *editPeopleButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editPeopleBarButtonItemPressed)];
    self.editPeopleButton = editPeopleButton;
    //UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(settingsBarButtonItemPressed)];
    //settingsButton.image = [UIImage imageNamed:@"Icon_Gear"];
    //self.settingsButton = settingsButton;
    
    UIBarButtonItem *addPersonButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPersonBarButtonItemPressed)];
    self.addPersonButton = addPersonButton;
    
    
    self.navigationItem.rightBarButtonItems = @[editButton];
}
-(void)addPersonBarButtonItemPressed
{
    [self performSegueWithIdentifier:@"AddPersonWithoutAppSegue" sender:self];
    
}

-(void)editBarButtonItemPressed
{
    if(self.schedule.assignmentsGenerated){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Assignments Already Generated" message:@"Are you sure you want to edit?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self changeMyScheduleTableViewToEditMode];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        [self changeMyScheduleTableViewToEditMode];
    }
    
}
-(void)changeMyScheduleTableViewToEditMode
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingMyScheduleButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditingMyScheduleButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    MeScheduleViewController *msvc = (MeScheduleViewController *)self.currentViewController;
    [msvc.tableView setEditing:true animated:YES];
    
}
-(void)doneEditingMyScheduleButtonPressed
{
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.navigationItem.leftBarButtonItem = nil;
    MeScheduleViewController *msvc = (MeScheduleViewController *)self.currentViewController;
    [msvc.tableView setEditing:false animated:YES];
    [msvc saveEdits];
}
-(void)cancelEditingMyScheduleButtonPressed
{
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.navigationItem.leftBarButtonItem = nil;
    MeScheduleViewController *msvc = (MeScheduleViewController *)self.currentViewController;
    [msvc.tableView setEditing:false animated:YES];

}
-(void)settingsBarButtonItemPressed
{
    [self performSegueWithIdentifier:@"MyScheduleSettingsSegue" sender:self];
}

-(void)editPeopleBarButtonItemPressed
{
    [self.viewControllers[2] setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = self.addPersonButton;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneEditingPeopleButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
}
-(void)doneEditingPeopleButtonPressed
{
    [self.viewControllers[2] setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editPeopleButton;
    self.navigationItem.leftBarButtonItem = nil;
    
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

    HomeGame *hg = self.schedule.homeGame;
    self.labelOpponent.text = hg.opponentName;
    self.labelDate.text = [[[Constants formatDate:self.schedule.endDate withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "] stringByAppendingString:[Constants formatTime:self.schedule.endDate withStyle:NSDateFormatterShortStyle]];

    self.navigationItem.title = self.schedule.groupName;
    
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
    if([self.viewControllers[index] isKindOfClass:[MeScheduleViewController class]] && (self.schedule.personsArray.count > 0)){
        
        //TODO: this gets called every time segment index is switched. should really only happen once, or once every time there's an update to current user's schedule
        MeScheduleViewController *msvc = self.viewControllers[index];
        msvc.currentPerson = self.schedule.personsArray[[self.schedule findCurrentUserPersonIndex]]; //TODO: there's an error here when someone first joins a schedule
        msvc.schedule = self.schedule;
        
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
        vc.view.frame = [self frameForContentController];
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
    
    
    // Me
    if([newVC isKindOfClass:[MeScheduleViewController class]]){
        MeScheduleViewController *msvc = (MeScheduleViewController *)newVC;
        msvc.schedule = self.schedule;
        
        
        self.navigationItem.rightBarButtonItems = self.schedule.assignmentsGenerated ? nil : @[self.editButton];
        
    }
    
    // Current
    else if ([newVC isKindOfClass:[PersonsInIntervalViewController class]]){
        PersonsInIntervalViewController *piivc = (PersonsInIntervalViewController *)newVC;
        piivc.schedule = self.schedule;
        piivc.displayCurrent = YES;
        self.navigationItem.rightBarButtonItems = @[];
        
        
    }
    
    // Others
    else if([newVC isKindOfClass:[PickPersonTableViewController class]]){
        PickPersonTableViewController *pptvc = (PickPersonTableViewController *)newVC;
        pptvc.schedule = self.schedule;
        
        if(self.isCreator){
            self.navigationItem.rightBarButtonItems = @[self.editPeopleButton];
        }else{
            self.navigationItem.rightBarButtonItems = @[];
        }
    }
    
    // Time Slots
    else if ([newVC isKindOfClass:[IntervalsTableViewController class]]){
        IntervalsTableViewController *itvc = (IntervalsTableViewController *)newVC;
        itvc.schedule = self.schedule ;
        self.navigationItem.rightBarButtonItems = @[];
        
    }

    CGRect frame = CGRectMake(-self.containerView.bounds.size.width, self.containerView.bounds.origin.y, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    newVC.view.frame = frame;
    //CGRect endFrame = CGRectMake(2*self.containerView.bounds.size.width, self.containerView.bounds.origin.y, self.containerView.bounds.size.width, self.containerView.bounds.size.height);

    [self transitionFromViewController:oldVC toViewController:newVC duration:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [oldVC.view removeFromSuperview];
        [self.containerView addSubview:newVC.view];
        //newVC.view.frame = oldVC.view.frame;
        //oldVC.view.frame = endFrame;

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




/*
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
 */
//same as updateSchedule in HomeBase. Consolidate this
-(void)updateSchedule
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    
    PFQuery *query = [PFQuery queryWithClassName:kGroupScheduleClassName];
    [query includeKey:kGroupSchedulePropertyPersonsInGroup];
    [query includeKey:kGroupSchedulePropertyHomeGame];
    [query includeKey:kGroupSchedulePropertyCreatedBy];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", kGroupSchedulePropertyPersonsInGroup, kPersonPropertyAssociatedUser]];
    [query getObjectInBackgroundWithId:self.schedule.parseObjectID block:^(PFObject *parseSchedule, NSError *error) {
        if(error){
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
    HomeGame *hg = self.schedule.homeGame;
    NSDictionary *sectionAdmin = @{
                                   @"sectionHeader":@"Admin",
                                   @"sectionData": @[]
                                   };
    NSDictionary *sectionGeneral = @{
                               @"sectionHeader":@"General",
                               @"sectionData": @[
                                   @{
                                       @"title": @"Schedule Name:",
                                       @"value": self.schedule.groupName,
                                       },
                                   @{
                                       @"title": @"Opponent:",
                                       @"value": hg.opponentName,
                                       },
                                   @{
                                       @"title": @"Group Code:",
                                       @"value": self.schedule.groupCode,
                                       
                                       },
                                   @{
                                       @"title": @"Creator:",
                                       @"value": [self.schedule.createdBy objectForKey:kUserPropertyFullName],
                                       }
                                   
                                   ],
                               };
    NSDictionary *sectionDates = @{
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
                                           @"value": hg.gameTime,
                                           
                                           }
                                       ],
                               };
    NSDictionary *sectionStats = @{
                                   @"sectionHeader":@"Stats",
                                   @"sectionData": @[]
                                   };
    
    return self.isCreator ? @{@0:sectionAdmin,@1:sectionGeneral, @2:sectionDates, @3:sectionStats} : @{@0:sectionGeneral, @1:sectionDates, @3:sectionStats};

}


-(IBAction)closeSettings:(UIStoryboardSegue *)segue
{
}
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
         UINavigationController *nc = [segue destinationViewController];
         if([nc.childViewControllers[0] isKindOfClass:[ScheduleSettingsViewController class]]){
             
             //TODO: decide which objects to pass
             ScheduleSettingsViewController *ssvc = (ScheduleSettingsViewController *)nc.childViewControllers[0];
             ssvc.settings = [self createSettingsDictionary];
             ssvc.schedule = self.schedule;
             ssvc.isCreator = self.isCreator;
             
         }
    }
 }



@end
