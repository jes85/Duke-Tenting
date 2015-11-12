//
//  JoinScheduleTableViewController.m
//  Tent
//
//  Created by Jeremy on 8/31/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "JoinScheduleTableViewController.h"
#import "Schedule.h"
#import <Parse/Parse.h>
#import "ScheduleTableViewCell.h"
#import "MySchedulesTableViewController.h"
#import "Constants.h"
#import "SortGroupsViewController.h"

#define kEnterPasswordAlertViewTitle            @"Enter Group Code: "
#define kCancelButtonTitle                      @"Cancel"
#define kEnterButtonTitle                       @"Enter"

#define kWrongPasswordAlertViewTitle            @"Incorrect!"
#define kWrongPasswordAlertViewMessage          @"Please enter the group code again."

@interface JoinScheduleTableViewController ()

@property (nonatomic) Schedule *scheduleToJoin;
@property (nonatomic) NSArray *searchResults;
@property (nonatomic) UIAlertAction *cancelAlertAction;

@end

@implementation JoinScheduleTableViewController

-(UIAlertAction *)cancelAlertAction
{
    if(!_cancelAlertAction){
        _cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    }
    return _cancelAlertAction;
}

#pragma mark - View Controller Lifecycle
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getSchedulesAssociatedWithHomeGameIndex];
    
    
}

/*!
 * Query Parse to get all the schedules that have been created for the selected home game
 */
-(void)getSchedulesAssociatedWithHomeGameIndex
{
    
    PFQuery *query = [PFQuery queryWithClassName:kScheduleClassName];
    [query whereKey:kSchedulePropertyHomeGameIndex equalTo:[NSNumber numberWithInteger:self.homeGameIndex ]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedules, NSError *error) {
        if(!schedules){
            NSLog(@"Find failed");
        }else if ([schedules count]<1){
            NSLog(@"No schedules associated with home game index %lu in Parse", (unsigned long)self.homeGameIndex);
        }else{
            NSLog(@"Find schedules associated with home game index %lu succeeded", (unsigned long)self.homeGameIndex);
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for(PFObject *parseSchedule in schedules){
                
                Schedule *scheduleObject = [MySchedulesTableViewController createScheduleObjectFromParseInfo:parseSchedule] ;
                
                [array addObject:scheduleObject];
            }
            
            self.schedulesAssociatedWithThisHomeGame = [array sortedArrayUsingDescriptors:[self getSortDescriptors]];
            [self.tableView reloadData];
            
        }
    }];
    
    
}

-(NSArray *)getSortDescriptors
{
    NSArray *sortDescriptors;
    NSSortDescriptor *sortByScheduleName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortByCreatorName = [NSSortDescriptor sortDescriptorWithKey:@"creatorName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
;
    NSSortDescriptor *sortByStartDate = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
    
    switch (self.filterBy) {
        case 0: //schedule name
            sortDescriptors = @[sortByScheduleName, sortByCreatorName, sortByStartDate];
            
            break;
        case 1: //creator name
            sortDescriptors = @[sortByCreatorName, sortByScheduleName, sortByStartDate];
            break;
        case 2: //start date
            sortDescriptors = @[sortByStartDate, sortByScheduleName, sortByCreatorName];
            break;
            
        default:
            sortDescriptors = @[sortByScheduleName, sortByStartDate, sortByCreatorName];
            break;
    }
    return sortDescriptors;
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
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.searchResults count];
    }else{
        return [self.schedulesAssociatedWithThisHomeGame count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *reuseIdentifier = @"joinScheduleCell";
   ScheduleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ScheduleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    
    Schedule *schedule = nil;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        schedule = self.searchResults[indexPath.row];
    }else{
        schedule = self.schedulesAssociatedWithThisHomeGame[indexPath.row];
    }
    
    // Configure the cell...
    cell.nameLabel.text = schedule.name;
    cell.startDate.text = [[[Constants formatDate:schedule.startDate withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "]stringByAppendingString:[Constants formatTime:schedule.startDate withStyle:NSDateFormatterShortStyle]];
     cell.endDate.text = [[[Constants formatDate:schedule.endDate withStyle:NSDateFormatterShortStyle] stringByAppendingString:@" "]stringByAppendingString:[Constants formatTime:schedule.endDate withStyle:NSDateFormatterShortStyle]];
    cell.creatorLabel.text = schedule.creatorName;
    
    /* If I've already joined one of the schedules, display this one first, distinguish it with a checkmark, and disable the join button on the other schedules
     
        if([self.mySchedules containsObject:schedule]) {
        cell.detailTextLabel.text = @"Joined";
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
     */
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self displayEnterPasswordAlertForScheduleIndex:indexPath.row];
}

-(void)displayEnterPasswordAlertForScheduleIndex:(NSInteger)scheduleIndex
{
    if(self.searchDisplayController.active){
        self.scheduleToJoin = self.searchResults[scheduleIndex];
    }else{
        self.scheduleToJoin = self.schedulesAssociatedWithThisHomeGame[scheduleIndex];
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:kEnterPasswordAlertViewTitle
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    UIAlertAction* joinAction = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self tryToJoinSchedule:alert];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:joinAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Group Code";
        textField.secureTextEntry = YES;
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)tryToJoinSchedule:(UIAlertController *)alert
{
    UITextField *passwordTextField = alert.textFields.firstObject;
    NSString *passwordAttempt = passwordTextField.text;
    if([passwordAttempt isEqualToString:self.scheduleToJoin.password]){
        alert.title = @"Success";
        [self performSegueWithIdentifier:@"joinedSchedule" sender:self];
    }else{
        alert.title = kWrongPasswordAlertViewTitle;
        alert.message = kWrongPasswordAlertViewMessage;
        passwordTextField.text = nil;
        [self presentViewController:alert animated:YES completion:nil];
    }

}

#pragma mark - Search Bar
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(name contains[c] %@) OR (creatorName contains[c] %@)", searchText, searchText];
    self.searchResults = [self.schedulesAssociatedWithThisHomeGame filteredArrayUsingPredicate:resultPredicate];
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Custom buttons
/*!
 * Called when user taps Join button.
 * Asks user to enter the group code
 */
-(void)buttonPressed:(UITableViewCell *)cell
{
    NSIndexPath *indexPath;
    if (self.searchDisplayController.active) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
    } else {
        indexPath = [self.tableView indexPathForCell:cell];
    }
    
    //if([self.scheduleToJoin.privacy isEqualToString: @"private"]){
    
    [self displayEnterPasswordAlertForScheduleIndex:indexPath.row];

}

-(IBAction)doneFilter:(UIStoryboardSegue *)segue
{
    self.schedulesAssociatedWithThisHomeGame = [self.schedulesAssociatedWithThisHomeGame sortedArrayUsingDescriptors:[self getSortDescriptors]];
    [self.tableView reloadData];
    
}
-(IBAction)cancelFilter:(UIStoryboardSegue *)segue
{
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue destinationViewController] isKindOfClass:[MySchedulesTableViewController class]]){
        MySchedulesTableViewController *mstvc = [segue destinationViewController];
        mstvc.scheduleToJoin = self.scheduleToJoin;
    }else if([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *nc = [segue destinationViewController];
        if([nc.childViewControllers[0] isKindOfClass:[SortGroupsViewController class]]){
            SortGroupsViewController *sgvc = nc.childViewControllers[0];
            sgvc.selectedRow = self.filterBy;
        }
    }
}


@end
