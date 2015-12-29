//
//  MyScheduleViewController.m
//  Tent
//
//  Created by Jeremy on 12/25/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MyScheduleViewController.h"
#import "EnterScheduleTableViewController.h"
#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalTableViewCell.h"
#import "Interval.h"
#import "Constants.h"
#import "PersonsInIntervalViewController.h"
#import "StatsViewController.h"
@interface MyScheduleViewController ()

@property (nonatomic) UIBarButtonItem *cancelButton; //should be weak
@property(nonatomic, strong) NSMutableArray *updatedAvailabilitiesArray;

@property (nonatomic) BOOL isMe;
@property (nonatomic) BOOL isCreator;
@property (nonatomic) BOOL canEdit;
@end

@implementation MyScheduleViewController


-(UIBarButtonItem *)cancelButton
{
    if(!_cancelButton) _cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    return _cancelButton;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.allowsSelection = NO;
    self.navigationItem.leftBarButtonItem = nil;
    [self decideIfEditingIsAllowed];
   
    if(self.canEdit){
        [self changeNavBarToShowEditButton];
    }else{
    }
    //[self scrollToCurrentInterval];
    
    //TODO: note: this is called in MeSchedule before prepareForSegue stuff in container vc. Maybe subclass twice and override viewDidAppear and viewDidLoad appropriately
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([self.schedule.startDate timeIntervalSinceNow] < 0 && [self.schedule.endDate timeIntervalSinceNow] > 0){
        [self scrollToCurrentInterval];

    }
}
-(void)scrollToCurrentInterval
{
    NSInteger overallRow = [PersonsInIntervalViewController findCurrentTimeIntervalIndexForSchedule:self.schedule];
    if(overallRow < 0) return; //schedule hasn't started
    NSIndexPath *indexPath = [Constants indexPathForOverallRow:overallRow tableView:self.tableView];
    NSUInteger index = indexPath.row;
    NSUInteger section = indexPath.section;
    NSUInteger rows = [self.tableView numberOfRowsInSection:section];
    NSUInteger sections = self.tableView.numberOfSections;
    //TODO: there is an edge case where indexPathForOverallRow is wrong (index 24 when there are only 24 rows)
    //think i might have fixed it
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}
#pragma mark - Accessor Methods

-(NSMutableArray *)updatedAvailabilitiesArray
{
    
    if(!_updatedAvailabilitiesArray)
        _updatedAvailabilitiesArray = [[NSMutableArray alloc]initWithArray:self.currentPerson.assignmentsArray];
    return _updatedAvailabilitiesArray;
}


#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableDictionary *sectionData = [self.schedule.intervalDataBySection objectForKey:[NSNumber numberWithInteger:section]];
    
    return sectionData[@"sectionHeader"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return self.schedule.intervalDataBySection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    NSMutableDictionary *sectionData = [self.schedule.intervalDataBySection objectForKey:[NSNumber numberWithInteger:section]];
    
    return [sectionData[@"intervalEndIndex"] integerValue] - [sectionData[@"intervalStartIndex"] integerValue];
    
}

/*
 * Custom table header view. Add constraints.
 */
/*
 -(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 UILabel *label1 = [[UILabel alloc] init];
 label1.frame = CGRectMake(10, 2, tableView.frame.size.width /2, 18);
 label1.text=@"Time";
 //label1.backgroundColor=[UIColor clearColor];
 label1.textAlignment= NSTextAlignmentLeft;
 
 UILabel *label2 = [[UILabel alloc] init];
 label2.frame = CGRectMake(tableView.frame.origin.x + tableView.frame.size.width/2, 2, tableView.frame.size.width/2, 18);
 label2.text=@"Status";
 //label2.backgroundColor=[UIColor clearColor];
 label2.textAlignment= NSTextAlignmentCenter;
 
 UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
 [view addSubview:label1];
 [view addSubview:label2];
 
 return view;
 
 
 
 }
 */


-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(tableView.numberOfSections < 2) return nil; //table view # sections = self.schedule.intervalDataBySection.count
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:tableView.numberOfSections];
    for(int i = 0; i<tableView.numberOfSections; i++){
        [array addObject: [NSString stringWithFormat:@"%d", i]];
    }
    
    return array;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString
                                                                             *)title atIndex:(NSInteger)index
{
    return index;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Interval Cell" forIndexPath:indexPath];
    cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.size.width/2;
    cell.iconImageView.clipsToBounds = YES;
    
    // Configure the cell...
    NSMutableDictionary *sectionData = [self.schedule.intervalDataBySection objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    
    NSUInteger index = [sectionData[@"intervalStartIndex"] integerValue] + indexPath.row;
    
    Interval *interval = self.schedule.intervalDataByOverallRow[index]; //might need to update this locally when updating people's schedules
    
    // TODO: decide whether to do this for each cell use or array
    NSUInteger numPeopleAssigned = [self.schedule numPeopleAssignedInIntervalIndex:index];
    NSUInteger numPeopleAvailable = [self.schedule numPeopleAvailableInIntervalIndex:index];
    NSString *warningText;
    if(self.schedule.assignmentsGenerated){
        warningText = [NSString stringWithFormat:@"%lu assigned out of %lu required", (unsigned long)numPeopleAssigned, (unsigned long)interval.requiredPersons];
        cell.warningLabel.textColor = [UIColor redColor];
    }else{
        warningText = [NSString stringWithFormat:@"%lu available out of %lu needed", (unsigned long)numPeopleAvailable, (unsigned long) interval.requiredPersons];
        cell.warningLabel.textColor = [UIColor orangeColor];
    }
    
    cell.warningLabel.text = warningText;
    //cell.textLabel.text =interval.timeString;
    cell.timeLabel.text = interval.timeString;
    
    
    //NSString *interval = self.schedule.hourIntervalsDisplayArray[indexPath.row];
    //cell.textLabel.text = interval;
    
    
    if([self.updatedAvailabilitiesArray[index] isEqual:@2]){
        cell.assignedOrAvailableLabel.text = @"(Assigned)";
        //cell.iconImageView.image =[UIImage imageNamed:@"GreenCircle"];
        cell.iconImageView.backgroundColor =[UIColor greenColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:0 green:.3 blue:0 alpha:1.0];
    }
    
    else if([self.updatedAvailabilitiesArray[index] isEqual:@1]) { //self.updatedAvailabilitiesArray instead of currentPerson.availabilitiesArray because the screen should show the updates as the user is making them. If they then hit cancel, those updates are not saved. UpdatedAvailabilitiesArray is reinitialized to currentPerson.availabilitiesArray every time the view loads
        cell.assignedOrAvailableLabel.text = @"(Available)";
        //cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.iconImageView.backgroundColor =[UIColor yellowColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        
    }
    else {
        cell.assignedOrAvailableLabel.text = @"(Unavailable)";
        //cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.iconImageView.backgroundColor =[UIColor blueColor];
        
        cell.assignedOrAvailableLabel.textColor = [UIColor blueColor];
    }
    
    
    //I don't think I should have to do this because I did it in a storyboards. There must be a way to add the images to the cell's content view in the storyboard
    [cell.contentView addSubview:cell.assignedOrAvailableLabel];
    [cell.contentView addSubview:cell.iconImageView];
    
    return cell;
}






#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *sectionData = [self.schedule.intervalDataBySection objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    
    NSUInteger index = [sectionData[@"intervalStartIndex"] integerValue] + indexPath.row;
    
    if(self.schedule.assignmentsGenerated){
        [self updateStatusAfterAssignmentsGeneratedForCell:cell AtIndex:index];
    }else{
        [self updateStatusBeforeAssignmentsGeneratedForCell:cell AtIndex:index];
    }
    
    
    
}

-(void)updateStatusBeforeAssignmentsGeneratedForCell:(IntervalTableViewCell *)cell AtIndex:(NSUInteger)index
{
    if([self.updatedAvailabilitiesArray[index] isEqual:@0]){
        
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        
        self.updatedAvailabilitiesArray[index] = @1;
        
        cell.assignedOrAvailableLabel.text = @"(Available)";
        //cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        
        cell.iconImageView.backgroundColor =[UIColor yellowColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        
        
    }
    else if([self.updatedAvailabilitiesArray[index] isEqual:@1]) {
        self.updatedAvailabilitiesArray[index] = @0;
        
        cell.assignedOrAvailableLabel.text = @"(Unavailable)";
        //cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.iconImageView.backgroundColor =[UIColor blueColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor blueColor];

        
    }

}

-(void)updateStatusAfterAssignmentsGeneratedForCell:(IntervalTableViewCell *)cell AtIndex:(NSUInteger)index
{
    if([self.updatedAvailabilitiesArray[index] isEqual:@2]){
        
        self.updatedAvailabilitiesArray[index] = @0;
        
        cell.assignedOrAvailableLabel.text = @"(Unavailable)";
        //cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.iconImageView.backgroundColor =[UIColor blueColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor blueColor];
        
    }
    else if([self.updatedAvailabilitiesArray[index] isEqual:@1]) {
        self.updatedAvailabilitiesArray[index] = @2;
        
        cell.assignedOrAvailableLabel.text = @"(Assigned)";
        cell.iconImageView.backgroundColor =[UIColor greenColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:0 green:.3 blue:0 alpha:1.0];
    }else if([self.updatedAvailabilitiesArray[index] isEqual:@0]){
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        
        self.updatedAvailabilitiesArray[index] = @1;
        
        cell.assignedOrAvailableLabel.text = @"(Available)";
        //cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.iconImageView.backgroundColor =[UIColor yellowColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
    }

}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    // overriding this method means we can attach custom functions to the button
    // this is the default action method for self.editButtonItem
    [super setEditing:editing animated:animated];
    
    // attaching custom actions here
    if (editing) {
        // we're in edit mode
        //[self.navigationItem setLeftBarButtonItem:self.cancelButton animated:animated];
        //self.tableView.allowsSelection = YES; //unnecessary because i set this in storyboard
        
    } else {
        // we're not in edit mode
        //[self.navigationItem setLeftBarButtonItem:nil animated:animated];
        //self.tableView.allowsSelection = NO;
        
        
    }
}
-(void)editButtonPressed
{
    if(self.schedule.assignmentsGenerated){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Assignments Already Generated" message:@"Are you sure you want to edit?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self changeToEditMode];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        [self changeToEditMode];
    }
}
-(void)changeToEditMode
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    [self.tableView setEditing:true animated:YES]; //true vs yes?
}
-(void)doneButtonPressed
{
    //do done button things
    [self saveEdits];
    [self changeNavBarToShowEditButton];
    [self.tableView setEditing:false animated:YES];
}
-(void)saveEdits
{
    
    //if current person's availabilities array was changed, update Person and Schedule on current iPhone and on Parse
    if(![self.currentPerson.assignmentsArray isEqual:self.updatedAvailabilitiesArray]){
        
        //update Person's availabilities array on local iPhone
        self.currentPerson.assignmentsArray = self.updatedAvailabilitiesArray;
        NSMutableArray *personsList = self.schedule.personsArray;
        [personsList removeObjectAtIndex:self.currentPerson.scheduleIndex];
        [personsList insertObject:self.currentPerson atIndex:self.currentPerson.scheduleIndex];
        self.schedule.personsArray = personsList;
        /*
         can i just do this? pointers or values
         Person *currentPerson = personsList[self.currentPerson.scheduleIndex];
         currentPerson = self.currentPerson;
         */
        
        //Update Person on Parse
        PFQuery *query = [PFQuery queryWithClassName:kPersonClassName];
        [query getObjectInBackgroundWithId:self.currentPerson.parseObjectID block:^(PFObject *object, NSError *error) {
            if(!object){
                NSLog(@"Find failed");
            }else{
                //the find succeeded
                NSLog(@"Find succeeded");
                object[kPersonPropertyAssignmentsArray] = self.currentPerson.assignmentsArray;
                [object saveInBackground];
            }
        }];
        
        //update Schedule on Parse
        
        // I don't think I have to update schedule anymore since i restructured data in parse
        /*
         PFQuery *query2 = [PFQuery queryWithClassName:@"Schedule"];
         [query2 whereKey:@"name" equalTo:self.currentPerson.scheduleName];
         [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
         if(!object){
         NSLog(@"Find failed");
         }else{
         //the find succeeded
         NSLog(@"Find succeeded");
         NSMutableArray *array = object[@"availabilitiesSchedule"] ;
         array[self.currentPerson.scheduleIndex]= self.currentPerson.assignmentsArray;
         object[@"availabilitiesSchedule"] =array;
         
         [object saveInBackground];
         }
         }];
         */
        
        
        //update Intervals offline
        for(int i = 0; i<[self.currentPerson.assignmentsArray count]; i++){
            Interval *interval = (Interval *)self.schedule.intervalDataByOverallRow[i];
            if([self.currentPerson.assignmentsArray[i] isEqual:@1]) {
                if(![interval.availablePersons containsObject:self.currentPerson]){
                    [interval.availablePersons addObject: self.currentPerson];
                }
            }
            if([self.currentPerson.assignmentsArray[i] isEqual:@2]) {
                if(![interval.assignedPersons containsObject:self.currentPerson]){
                    [interval.assignedPersons addObject:self.currentPerson];
                }
            }
        }
    }
    
    
    
}
-(void)cancelButtonPressed
{
    //do cancel button things
    
    [self changeNavBarToShowEditButton];
    [self.tableView setEditing:false animated:YES];
}
-(void)changeNavBarToShowEditButton
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.navigationItem.leftBarButtonItem = nil;
}

-(void)decideIfEditingIsAllowed
{
    self.isMe = [self.currentPerson.user.objectId isEqualToString:[[PFUser currentUser] objectId]];
    self.isCreator = [self.schedule.createdBy.objectId isEqualToString: [[PFUser currentUser] objectId]];
    self.canEdit =  (self.isMe && !self.schedule.assignmentsGenerated) | self.isCreator ;
}
- (IBAction)helpButtonPressed:(id)sender {
    
    
    NSString *message;
    if(!self.canEdit){
        if(self.isMe) message = @"Assignments have already been generated. Only the creator can edit the schedule now.";
        else message = @"You do not have access to edit this person's schedule. Only this person and the group creator have access.";
    }else{
        message = @"Press edit and tap a cell to change the availability status for that time interval";
    }
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"Help" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    
    //TODO: figure how way to keep schedule object data consistent across multiple view controllers
    /*self.schedule may have changed. need to update all schedule objects on local iphone. maybe with delegate
     */
    
    if([segue.destinationViewController isKindOfClass:[StatsViewController class]]){
        StatsViewController *svc = segue.destinationViewController;
        svc.schedule = &_schedule;
        
    }
}


@end
