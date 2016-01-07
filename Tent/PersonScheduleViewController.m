//
//  PersonScheduleViewController.m
//  Tent
//
//  Created by Jeremy on 1/1/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import "PersonScheduleViewController.h"

#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalTableViewCell.h"
#import "Interval.h"
#import "PersonsInIntervalViewController.h"
#import "StatsViewController.h"

@interface PersonScheduleViewController ()


@end

@implementation PersonScheduleViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.allowsSelection = NO;

    //TODO: note: viewDidLoad is called in MeSchedule before prepareForSegue stuff in container vc. Maybe subclass twice and override viewDidAppear and viewDidLoad appropriately
}


-(void)scrollToCurrentInterval
{
    NSInteger overallRow = [PersonsInIntervalViewController findCurrentTimeIntervalIndexForSchedule:self.schedule];
    if(overallRow < 0) return; //schedule hasn't started
    NSIndexPath *indexPath = [Constants indexPathForOverallRow:overallRow tableView:self.tableView];
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
-(NSMutableArray *)updatedIntervalDataByOverallRowArray
{
    if(!_updatedIntervalDataByOverallRowArray) {
        /*
        NSMutableArray *test = self.schedule.intervalDataByOverallRow;
        NSMutableArray *test2 = [self.schedule.intervalDataByOverallRow copy];
        NSMutableArray *test3 = [[NSMutableArray alloc]initWithArray:self.schedule.intervalDataByOverallRow copyItems:YES];
         */
        _updatedIntervalDataByOverallRowArray = [[NSMutableArray alloc]initWithArray:self.schedule.intervalDataByOverallRow copyItems:YES];
    }
    return _updatedIntervalDataByOverallRowArray;
}

-(BOOL)canEdit{
    return (self.isMe && !self.schedule.assignmentsGenerated) | self.isCreator ;
}
-(BOOL)isCreator{
    return [[[PFUser currentUser] objectId] isEqual: self.schedule.createdBy.objectId];
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
    
    // TODO: decide whether to do this for each cell or use array
    //NSUInteger numPeopleAssigned = [self.schedule numPeopleAssignedInIntervalIndex:index];
    //NSUInteger numPeopleAvailable = [self.schedule numPeopleAvailableInIntervalIndex:index];
    //I changed this
    //Interval *interval = self.schedule.intervalDataByOverallRow[index]; //might need to update this locally when updating people's schedules. //i think i do
    Interval *interval = self.updatedIntervalDataByOverallRowArray[index];
    [self changeWarningTextForCell:cell intervalIndex:index assignmentsGenerated:self.schedule.assignmentsGenerated];
    
    cell.timeLabel.text = interval.timeString;
    
    if(interval.night){
        
    }
    cell.backgroundColor = interval.night ? [UIColor grayColor] : [UIColor clearColor];
    if([self.updatedAvailabilitiesArray[index] isEqual:@2]){
        cell.assignedOrAvailableLabel.text = @"(Assigned)";
        //cell.iconImageView.image =[UIImage imageNamed:@"GreenCircle"];
        cell.iconImageView.backgroundColor =[UIColor greenColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:0 green:.3 blue:0 alpha:1.0];
    }
    
    else if([self.updatedAvailabilitiesArray[index] isEqual:@1]) { //self.updatedAvailabilitiesArray instead of currentPerson.availabilitiesArray because the screen should show the updates as the user is making them. If they then hit cancel, those updates are not saved. UpdatedAvailabilitiesArray is reinitialized to currentPerson.availabilitiesArray every time the view loads
        cell.assignedOrAvailableLabel.text = @"(Available)";
        //cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.iconImageView.backgroundColor =[UIColor orangeColor];
        //cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        cell.assignedOrAvailableLabel.textColor = [UIColor orangeColor];
        
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
        
        cell.iconImageView.backgroundColor =[UIColor orangeColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor orangeColor];
        
        
        Interval *interval = self.updatedIntervalDataByOverallRowArray[index];
        [interval.availablePersons addObject:self.currentPerson];
        [self changeWarningTextForCell:cell intervalIndex:index assignmentsGenerated:self.schedule.assignmentsGenerated];
        
    }
    else if([self.updatedAvailabilitiesArray[index] isEqual:@1]) {
        self.updatedAvailabilitiesArray[index] = @0;
        
        cell.assignedOrAvailableLabel.text = @"(Unavailable)";
        //cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.iconImageView.backgroundColor =[UIColor blueColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor blueColor];
        
        Interval *interval = self.updatedIntervalDataByOverallRowArray[index];
        [interval.availablePersons removeObject:self.currentPerson];
        [self changeWarningTextForCell:cell intervalIndex:index assignmentsGenerated:self.schedule.assignmentsGenerated];
    }
    
}
-(void)changeWarningTextForCell:(IntervalTableViewCell *)cell intervalIndex:(NSUInteger)index assignmentsGenerated:(BOOL)assignmentsGenerated
{
    Interval *interval = self.updatedIntervalDataByOverallRowArray[index];
    NSString *assignedOrAvailable;
    UIColor *labelColor;
    NSUInteger count;
    if(assignmentsGenerated){
        assignedOrAvailable = @"assigned";
        labelColor = [UIColor redColor];
        count = interval.assignedPersons.count;
    }else{
        assignedOrAvailable = @"available";
        labelColor = [UIColor redColor];
        count = interval.availablePersons.count;
    }
    NSString *warningText;
    if((count < interval.requiredPersons) | (count > interval.requiredPersons && assignmentsGenerated)){
        warningText = [NSString stringWithFormat:@"Warning: %lu %@ out of %lu required", (unsigned long)count, assignedOrAvailable, (unsigned long)interval.requiredPersons];
        
    }
    cell.warningLabel.text = warningText;
    cell.warningLabel.textColor = labelColor;

}
-(void)updateStatusAfterAssignmentsGeneratedForCell:(IntervalTableViewCell *)cell AtIndex:(NSUInteger)index
{
    if([self.updatedAvailabilitiesArray[index] isEqual:@2]){
        
        self.updatedAvailabilitiesArray[index] = @0;
        
        cell.assignedOrAvailableLabel.text = @"(Unavailable)";
        //cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.iconImageView.backgroundColor =[UIColor blueColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor blueColor];
        
        Interval *interval = self.updatedIntervalDataByOverallRowArray[index];
        [interval.assignedPersons removeObject:self.currentPerson];
        [interval.availablePersons removeObject:self.currentPerson];
        [self changeWarningTextForCell:cell intervalIndex:index assignmentsGenerated:self.schedule.assignmentsGenerated];

        
    }
    else if([self.updatedAvailabilitiesArray[index] isEqual:@1]) {
        self.updatedAvailabilitiesArray[index] = @2;
        
        cell.assignedOrAvailableLabel.text = @"(Assigned)";
        cell.iconImageView.backgroundColor =[UIColor greenColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:0 green:.3 blue:0 alpha:1.0];
        
        Interval *interval = self.updatedIntervalDataByOverallRowArray[index];
        [interval.assignedPersons addObject:self.currentPerson];
        [self changeWarningTextForCell:cell intervalIndex:index assignmentsGenerated:self.schedule.assignmentsGenerated];

    }else if([self.updatedAvailabilitiesArray[index] isEqual:@0]){
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        
        self.updatedAvailabilitiesArray[index] = @1;
        
        cell.assignedOrAvailableLabel.text = @"(Available)";
        //cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.iconImageView.backgroundColor =[UIColor orangeColor];
        cell.assignedOrAvailableLabel.textColor = [UIColor orangeColor];
        
        Interval *interval = self.updatedIntervalDataByOverallRowArray[index];
        [interval.availablePersons addObject:self.currentPerson];
        [self changeWarningTextForCell:cell intervalIndex:index assignmentsGenerated:self.schedule.assignmentsGenerated];

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
-(void)saveEdits
{
    
    //if current person's availabilities array was changed, update Person and Schedule on current iPhone and on Parse
    if(![self.currentPerson.assignmentsArray isEqual:self.updatedAvailabilitiesArray]){
        
        
        //Update Person on Parse
        PFQuery *query = [PFQuery queryWithClassName:kPersonClassName];
        [query getObjectInBackgroundWithId:self.currentPerson.parseObjectID block:^(PFObject *object, NSError *error) {
            if(!object){
                //Find failed
                NSLog(@"%@", [error userInfo]);
            }else{ // Find succeeded
                object[kPersonPropertyAssignmentsArray] = self.updatedAvailabilitiesArray;
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        //update Person's availabilities array on local iPhone
                        self.currentPerson.assignmentsArray = [self.updatedAvailabilitiesArray mutableCopy];
                        NSMutableArray *personsList = self.schedule.personsArray;
                        [personsList removeObjectAtIndex:self.currentPerson.scheduleIndex];
                        [personsList insertObject:self.currentPerson atIndex:self.currentPerson.scheduleIndex];
                        self.schedule.personsArray = personsList;
                        /*
                         can i just do this? pointers or values
                         Person *currentPerson = personsList[self.currentPerson.scheduleIndex];
                         currentPerson = self.currentPerson;
                         or currentPerson.assignmentsArray = self.currentPerson.assignmentsArray
                         */
                        //update Intervals offline
                        //instead of this, can just compare currentPerson and updated and only update intervals that were changed
                        //TODO: or can keep track of changed intervals as they occur so we don't have to loop through all intervals here
                        /*
                         for(int i = 0; i<[self.currentPerson.assignmentsArray count]; i++){
                         Interval *interval = (Interval *)self.schedule.intervalDataByOverallRow[i];
                         if([self.currentPerson.assignmentsArray[i] isEqual:@0]) {
                         if([interval.availablePersons containsObject:self.currentPerson]){
                         [interval.availablePersons removeObject: self.currentPerson];
                         }
                         if([interval.assignedPersons containsObject:self.currentPerson]){
                         [interval.assignedPersons removeObject:self.currentPerson];
                         }
                         }
                         else if([self.currentPerson.assignmentsArray[i] isEqual:@1]) {
                         if(![interval.availablePersons containsObject:self.currentPerson]){
                         [interval.availablePersons addObject: self.currentPerson];
                         }
                         }
                         else if([self.currentPerson.assignmentsArray[i] isEqual:@2]) {
                         if(![interval.availablePersons containsObject:self.currentPerson]){
                         [interval.availablePersons addObject: self.currentPerson];
                         }
                         if(![interval.assignedPersons containsObject:self.currentPerson]){
                         [interval.assignedPersons addObject:self.currentPerson];
                         }
                         }
                         }*/
                        [self.schedule createIntervalDataArrays]; //ineffient but works for now
                        
                        //notify other vcs
                        NSDictionary *userInfo = @{kUserInfoLocalScheduleKey:self.schedule, kUserInfoLocalScheduleChangedPropertiesKey:@[kUserInfoLocalSchedulePropertyPersonsArray]};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameScheduleChanged object:self userInfo:userInfo];
                    }else{
                        
                        NSLog(@"Save Failed");
                    }
                }];
                
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
        
        
        
    }
    
    
    
}

- (IBAction)helpButtonPressed:(id)sender {
    
    
    NSString *message;
    if(!self.canEdit){
        if(self.isMe) message = @"Assignments have already been generated. Only the creator can edit the schedule now.";
        else message = @"You do not have access to edit this person's schedule. Only this person and the group creator have access.";
    }else{
        message = @"Press edit and tap a cell to change the availability status for that time interval.";
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
        svc.schedule = self.schedule;
        svc.person = self.currentPerson;
        
    }
}


@end
