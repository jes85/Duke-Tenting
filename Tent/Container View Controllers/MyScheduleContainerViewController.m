//
//  MyScheduleContainerViewController.m
//  Tent
//
//  Created by Jeremy on 10/8/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MyScheduleContainerViewController.h"

#import <Parse/Parse.h>
#import "Constants.h"
#import "Person.h"
#import "Interval.h"
#import "MySchedulesTableViewController.h"
#import "PickPersonTableViewController.h"
#import "IntervalsTableViewController.h"
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


@property (nonatomic) UIBarButtonItem *editMeScheduleButton;
@property (nonatomic) UIBarButtonItem *editPeopleButton;
@property (nonatomic) UIBarButtonItem *addPersonButton;


@end

@implementation MyScheduleContainerViewController


#pragma mark - View Controller Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    // Update display
    [self updateGameLabels];
    
    // Display Me Schedule in Container view
    [self displayViewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleChanged:) name:kNotificationNameScheduleChanged object:nil];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)updateGameLabels
{
    
    HomeGame *hg = self.schedule.homeGame;
    self.labelOpponent.text = hg.opponentName;
    self.labelDate.text = [[[Constants formatDate:self.schedule.endDate withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "] stringByAppendingString:[Constants formatTime:self.schedule.endDate withStyle:NSDateFormatterShortStyle]];
    
    self.navigationItem.title = self.schedule.groupName;
    
}

#pragma mark - Local Schedule Changed Notification
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}
-(void)scheduleChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    Schedule *schedule = userInfo[kUserInfoLocalScheduleKey];
    //update data
    self.schedule = schedule;
    
    //update UI
    NSArray *changedProperties = userInfo[kUserInfoLocalScheduleChangedPropertiesKey];
    if([changedProperties containsObject:kUserInfoLocalSchedulePropertyGroupName]){
        self.navigationItem.title = self.schedule.groupName;
    }
    
    //maybe update self.viewcontrollers' schedules too and update them. instead of each of them having a notification
   
}

#pragma mark - Bar Button Items
-(void)addPersonBarButtonItemPressed
{
    [self performSegueWithIdentifier:@"AddPersonWithoutAppSegue" sender:self];
    
}

-(UIBarButtonItem *)editMeScheduleButton{
    if(!_editMeScheduleButton) _editMeScheduleButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editMeScheduleButtonPressed)];
    return _editMeScheduleButton;
}

-(UIBarButtonItem *)editPeopleButton{
    if(!_editPeopleButton) _editPeopleButton =[[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editPeopleBarButtonItemPressed)];
    return _editPeopleButton;
}

-(UIBarButtonItem *)addPersonButton
{
    if(!_addPersonButton)_addPersonButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPersonBarButtonItemPressed)];
    return _addPersonButton;
    
}

-(BOOL)isCreator{
    return [[[PFUser currentUser] objectId] isEqual: self.schedule.createdBy.objectId];
}

-(void)editMeScheduleButtonPressed
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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneEditingMyScheduleButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditingMyScheduleButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    MeScheduleViewController *msvc = (MeScheduleViewController *)self.currentViewController;
    [msvc.tableView setEditing:true animated:YES];
    
}

-(void)doneEditingMyScheduleButtonPressed
{
    self.navigationItem.rightBarButtonItem = self.editMeScheduleButton;
    self.navigationItem.leftBarButtonItem = nil;
    MeScheduleViewController *msvc = (MeScheduleViewController *)self.currentViewController;
    [msvc.tableView setEditing:false animated:YES];
    [msvc saveEdits];
}

-(void)cancelEditingMyScheduleButtonPressed
{
    self.navigationItem.rightBarButtonItem = self.editMeScheduleButton;
    self.navigationItem.leftBarButtonItem = nil;
    MeScheduleViewController *msvc = (MeScheduleViewController *)self.currentViewController;
    [msvc.tableView setEditing:false animated:YES];
    msvc.updatedIntervalDataByOverallRowArray = nil;//msvc.schedule.intervalDataByOverallRow;
    msvc.updatedAvailabilitiesArray = nil;//msvc.currentPerson.assignmentsArray;
    [msvc.tableView reloadData];

}

-(void)editPeopleBarButtonItemPressed
{
    [self.viewControllers[2] setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = self.addPersonButton;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneEditingPeopleButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
}

-(void)doneEditingPeopleButtonPressed
{
    [self.viewControllers[2] setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editPeopleButton;
    self.navigationItem.leftBarButtonItem = nil;
    
}



#pragma mark - Refresh Schedule

- (IBAction)refreshButtonPressed:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:kGroupScheduleClassName];
    [query includeKey:kGroupSchedulePropertyPersonsInGroup];
    [query includeKey:kGroupSchedulePropertyHomeGame];
    [query includeKey:kGroupSchedulePropertyCreatedBy];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", kGroupSchedulePropertyPersonsInGroup, kPersonPropertyAssociatedUser]];
    
    [query getObjectInBackgroundWithId:self.schedule.parseObjectID block:^(PFObject * _Nullable parseSchedule, NSError * _Nullable error) {
        if(!error){
            Schedule *schedule = [MySchedulesTableViewController createScheduleObjectFromParseInfo:parseSchedule];
            if(schedule.currentUserWasRemoved){
                [self removeUserFromCurrentScheduleAndSegueBack];
            }else{
                //Can check if updated schedule is different first if i want
                [self refreshDataWithUpdatedSchedule:schedule];
            }
            
        }
    }];
}

-(void)refreshDataWithUpdatedSchedule:(Schedule *)updatedSchedule
{
    self.schedule = updatedSchedule;

    //update My Schedule, Current People, Persons, and Time intervals vcs
    //TODO: did this fast and it works, but can probably do it in a better way (i.e. just update current vc and then notify others
    self.viewControllers = [self instantiateViewControllers];
    
    NSUInteger index;
    if([self.currentViewController isKindOfClass:[MeScheduleViewController class]]){
        index = 0;
    }else if([self.currentViewController isKindOfClass:[NowPersonsInIntervalViewController class]]){
        index = 1;
    }else if([self.currentViewController isKindOfClass:[PickPersonTableViewController class]]){
        index = 2;
    }else if([self.currentViewController isKindOfClass:[IntervalsTableViewController class]]){
        index = 3;
    }
    [self cycleFromViewController:self.currentViewController toViewController:self.viewControllers[index]];
    self.currentViewController = self.viewControllers[index];
    
    self.navigationItem.title = self.schedule.groupName;
    
    //TODO: notify other vcs
   
    
}

// Caled if user was removed from the schedule by the creator
-(void)removeUserFromCurrentScheduleAndSegueBack
{
    [MySchedulesTableViewController removeSchedulesFromCurrentUser:@[self.schedule.parseObjectID]];
    //TODO: test this
    [self.navigationController popViewControllerAnimated:YES];

    
}

#pragma mark - Container View

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
        if([vc isKindOfClass:[MeScheduleViewController class]] && (self.schedule.personsArray.count > 0)){
            [self initializeFirstViewController:(MeScheduleViewController*)vc];
        }
        [array addObject:vc];
    }
    
    return array;
}
-(void)initializeFirstViewController:(MeScheduleViewController *)msvc
{

    msvc.currentPerson = self.schedule.personsArray[[self.schedule findCurrentUserPersonIndex]]; //TODO: there's an error here when someone first joins a schedule
    msvc.schedule = self.schedule;
    msvc.isCreator = self.isCreator;
    if([self.schedule.startDate timeIntervalSinceNow] < 0 && [self.schedule.endDate timeIntervalSinceNow] > 0){
        [msvc scrollToCurrentInterval];
        
    }
    self.navigationItem.rightBarButtonItems = msvc.canEdit ? @[self.editMeScheduleButton] : nil;
    self.navigationItem.leftBarButtonItem = nil;

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
    return self.viewControllers[index];
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
        msvc.currentPerson = self.schedule.personsArray[[self.schedule findCurrentUserPersonIndex]]; //TODO: there's an error here when someone first joins a schedule (there was, i may have fixe it
        msvc.schedule = self.schedule;
        msvc.isCreator = self.isCreator;
        
        
        self.navigationItem.rightBarButtonItems = msvc.canEdit ? @[self.editMeScheduleButton] : nil;
        self.navigationItem.leftBarButtonItem = nil;

        
    }
    
    // Current
    else if ([newVC isKindOfClass:[NowPersonsInIntervalViewController class]]){
        NowPersonsInIntervalViewController *piivc = (NowPersonsInIntervalViewController *)newVC;
        piivc.schedule = self.schedule;
        self.navigationItem.rightBarButtonItems = @[];
        self.navigationItem.leftBarButtonItem = nil;

        
        
    }
    
    // Others
    else if([newVC isKindOfClass:[PickPersonTableViewController class]]){
        PickPersonTableViewController *pptvc = (PickPersonTableViewController *)newVC;
        pptvc.schedule = self.schedule;
        
        if(self.isCreator){
            if(pptvc.tableView.isEditing){
                [self editPeopleBarButtonItemPressed];
            }else{
                [self doneEditingPeopleButtonPressed];
            }
        }else{
            self.navigationItem.rightBarButtonItems = @[];
            self.navigationItem.leftBarButtonItem = nil;

        }
        

    }
    
    // Time Slots
    else if ([newVC isKindOfClass:[IntervalsTableViewController class]]){
        IntervalsTableViewController *itvc = (IntervalsTableViewController *)newVC;
        itvc.schedule = self.schedule ;
        self.navigationItem.rightBarButtonItems = @[];
        self.navigationItem.leftBarButtonItem = nil;

        
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

#pragma mark - Segmented Control

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    if([self.currentViewController isKindOfClass:[MeScheduleViewController class]]){
        MeScheduleViewController *msvc = (MeScheduleViewController *)self.currentViewController;
        if(msvc.tableView.editing){
            sender.selectedSegmentIndex = 0;
            [self alertUserToSaveOrCancelEditsBeforeChangingSegments];
            return;
        }
    }
    UIViewController *newVC = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];

    [self cycleFromViewController:self.currentViewController toViewController:newVC];
    self.currentViewController = newVC;

}

-(void)alertUserToSaveOrCancelEditsBeforeChangingSegments
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wait!" message:@"Please save or cancel your edits first." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Settings Segue
// Maybe move this to Schedule Settings VC
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
                                   [NSMutableDictionary dictionaryWithDictionary:@{
                                       @"title": @"Group Name",
                                       @"value": self.schedule.groupName,
                                       @"isEditable" : [NSNumber numberWithBool:YES]
                                       }],
                                   [NSMutableDictionary dictionaryWithDictionary:@{
                                       @"title": @"Group Code",
                                       @"value": self.schedule.groupCode,
                                       @"isEditable" : [NSNumber numberWithBool:YES]
                                       
                                       }],
                                   @{
                                       @"title": @"Creator",
                                       @"value": [self.schedule.createdBy objectForKey:kUserPropertyFullName],
                                       @"isEditable" : [NSNumber numberWithBool:NO]
                                       }
                                   
                                   ],
                               };
    NSDictionary *sectionDates = @{
                               @"sectionHeader":@"Dates",
                               @"sectionData": @[
                                       @{
                                           @"title": @"Opponent",
                                           @"value": hg.opponentName,
                                           @"isEditable" : [NSNumber numberWithBool:NO]
                                           },

                                       @{
                                           @"title": @"Start Date",
                                           @"value": self.schedule.startDate,
                                           @"isEditable" : [NSNumber numberWithBool:NO]
                                           },
                                       @{
                                           @"title": @"End Date",
                                           @"value": self.schedule.endDate,
                                           @"isEditable" : [NSNumber numberWithBool:NO]
                                           },
                                       @{
                                           @"title": @"Game Time",
                                           @"value": hg.gameTime,
                                           @"isEditable" : [NSNumber numberWithBool:NO]
                                           
                                           }
                                       ],
                               };
    
    return self.isCreator ? @{@0:sectionAdmin,@1:sectionGeneral, @2:sectionDates} : @{@0:sectionGeneral, @1:sectionDates};
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
