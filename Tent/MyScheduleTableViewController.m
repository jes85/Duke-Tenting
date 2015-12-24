//
//  MyScheduleTableViewController.m
//  Tent
//
//  Created by Jeremy on 10/9/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MyScheduleTableViewController.h"

#import "EnterScheduleTableViewController.h"
#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalTableViewCell.h"
#import "Interval.h"
#import "Constants.h"
#import "PersonsInIntervalViewController.h"

@interface MyScheduleTableViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *editButton;
@property (nonatomic) UIBarButtonItem *cancelButton; //should be weak


@property(nonatomic, strong) NSMutableArray *updatedAvailabilitiesArray;


@end

@implementation MyScheduleTableViewController


//TODO: Add an Edit button for creator to remove members from schedule


-(UIBarButtonItem *)cancelButton
{
    if(!_cancelButton) _cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    return _cancelButton;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelection = NO;
    self.navigationItem.leftBarButtonItem = nil;
    if([self.schedule.createdBy.objectId isEqualToString: [[PFUser currentUser] objectId]] | [self.currentPerson.user.objectId isEqualToString:[[PFUser currentUser] objectId]]){//edit to check for user auth (it's my schedule & assignments haven't been made yet OR I'm an admin. if admin, show alert if assignments have already been made)
        [self changeNavBarToShowEditButton];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger overallRow = [PersonsInIntervalViewController findCurrentTimeIntervalIndexForSchedule:self.schedule];
    if(overallRow < 0) return; //schedule hasn't started
    NSIndexPath *indexPath = [Constants indexPathForOverallRow:overallRow tableView:self.tableView];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
    
    // Configure the cell...
    NSMutableDictionary *sectionData = [self.schedule.intervalDataBySection objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    
    NSUInteger index = [sectionData[@"intervalStartIndex"] integerValue] + indexPath.row;

    Interval *interval = self.schedule.intervalDataByOverallRow[index];
    
    cell.textLabel.text =interval.timeString;
    
    
    //NSString *interval = self.schedule.hourIntervalsDisplayArray[indexPath.row];
    //cell.textLabel.text = interval;
    
    
    if([self.updatedAvailabilitiesArray[index] isEqual:@2]){
        cell.assignedOrAvailableLabel.text = @"(Assigned)";
        cell.iconImageView.image =[UIImage imageNamed:@"GreenCircle"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:0 green:.3 blue:0 alpha:1.0];
    }
    
    else if([self.updatedAvailabilitiesArray[index] isEqual:@1]) { //self.updatedAvailabilitiesArray instead of currentPerson.availabilitiesArray because the screen should show the updates as the user is making them. If they then hit cancel, those updates are not saved. UpdatedAvailabilitiesArray is reinitialized to currentPerson.availabilitiesArray every time the view loads
        cell.assignedOrAvailableLabel.text = @"(Available)";
        cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        
    }
    else {
        cell.assignedOrAvailableLabel.text = @"";
        cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.assignedOrAvailableLabel.textColor = [UIColor redColor];
    }
    
    
    //I don't think I should have to do this because I did it in a storyboards. There must be a way to add the images to the cell's content view in the storyboard
    [cell.contentView addSubview:cell.assignedOrAvailableLabel];
    [cell.contentView addSubview:cell.iconImageView];
    
    return cell;
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
}


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *sectionData = [self.schedule.intervalDataBySection objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    
    NSUInteger index = [sectionData[@"intervalStartIndex"] integerValue] + indexPath.row;
    if([cell.assignedOrAvailableLabel.text isEqual:@""]){
        
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        
        self.updatedAvailabilitiesArray[index] = @1;
        
        cell.assignedOrAvailableLabel.text = @"(Available)";
        cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        
    }
    else {
        self.updatedAvailabilitiesArray[index] = @0;
        
        cell.assignedOrAvailableLabel.text = @"";
        cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.assignedOrAvailableLabel.textColor = [UIColor redColor];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    [self setEditing:true animated:YES]; //true vs yes?
}
-(void)doneButtonPressed
{
    //do done button things
    [self saveEdits];
    [self changeNavBarToShowEditButton];
    [self setEditing:false animated:YES];
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
    [self setEditing:false animated:YES];
}
-(void)changeNavBarToShowEditButton
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    self.navigationItem.rightBarButtonItem = editButton;

    self.navigationItem.leftBarButtonItem = nil;
}

@end
