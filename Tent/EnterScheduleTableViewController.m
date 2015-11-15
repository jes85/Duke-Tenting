//
//  EnterScheduleTableViewController.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "EnterScheduleTableViewController.h"
#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalTableViewCell.h"
#import "Interval.h"

@interface EnterScheduleTableViewController ()
@property(nonatomic, strong) NSMutableArray *updatedAvailabilitiesArray;


@property (nonatomic) UIBarButtonItem *cancelButton; //should be weak

@end

@implementation EnterScheduleTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(UIBarButtonItem *)cancelButton
{
    if(!_cancelButton) _cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    return _cancelButton;
}

#pragma mark - Accessor Methods

 -(NSMutableArray *)updatedAvailabilitiesArray
{
   
    if(!_updatedAvailabilitiesArray)
        _updatedAvailabilitiesArray = [[NSMutableArray alloc]initWithArray:self.currentPerson.availabilitiesArray];
    return _updatedAvailabilitiesArray;
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
   
    return [self.schedule.intervalDataByOverallRow count];
}


/*
 * Custom table header view. Add constraints.
*/
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Interval Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
   
    Interval *interval = self.schedule.intervalDataByOverallRow[indexPath.row];
    cell.textLabel.text = interval.timeString;
   
    
    if([self.currentPerson.assignmentsArray[indexPath.row] isEqual:@1]){
        cell.assignedOrAvailableLabel.text = @"(Assigned)";
        cell.iconImageView.image =[UIImage imageNamed:@"GreenCircle"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:0 green:.3 blue:0 alpha:1.0];
    }
    
    else if([self.updatedAvailabilitiesArray[indexPath.row] isEqual:@1]) { //self.updatedAvailabilitiesArray instead of currentPerson.availabilitiesArray because the screen should show the updates as the user is making them. If they then hit cancel, those updates are not saved. UpdatedAvailabilitiesArray is reinitialized to currentPerson.availabilitiesArray every time the view loads
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
    
    
    if(sender!=self.doneButton) return; //if user presses cancel button, don't do anything
    else{ //user pressed doneButton
        
        //if current person's availabilities array was changed, update Person and Schedule on current iPhone and on Parse
        if(![self.currentPerson.availabilitiesArray isEqual:self.updatedAvailabilitiesArray]){
        
            //update Person's availabilities array on local iPhone
            self.currentPerson.availabilitiesArray = self.updatedAvailabilitiesArray;
        
            //update schedule on local iPhone
            PickPersonTableViewController *pptvc = [segue destinationViewController];
            pptvc.schedule.availabilitiesSchedule[self.currentPerson.indexOfPerson] = self.currentPerson.availabilitiesArray;
            
            
            
            //Update Person on Parse
            PFQuery *query = [PFQuery queryWithClassName:@"Person"];
            [query whereKey:@"scheduleName" equalTo:self.currentPerson.scheduleName];
            [query whereKey:@"index" equalTo:[NSNumber numberWithInteger:self.currentPerson.indexOfPerson]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!object){
                    NSLog(@"Find failed");
                }else{
                    //the find succeeded
                    NSLog(@"Find succeeded");
                    object[@"availabilitiesArray"] = self.currentPerson.availabilitiesArray;
                    //object[@"assignmentsArray"] = self.currentPerson.assignmentsArray;
                    [object saveInBackground];
                }
            }];
        
            //update Schedule on Parse
        
            PFQuery *query2 = [PFQuery queryWithClassName:@"Schedule"];
            [query2 whereKey:@"name" equalTo:self.currentPerson.scheduleName];
            [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!object){
                    NSLog(@"Find failed");
                }else{
                    //the find succeeded
                    NSLog(@"Find succeeded");
                    NSMutableArray *array = object[@"availabilitiesSchedule"] ;
                    array[self.currentPerson.indexOfPerson]= self.currentPerson.availabilitiesArray;
                    object[@"availabilitiesSchedule"] =array;
                
                    [object saveInBackground];
                }
            }];
        
        
            //update Intervals offline
            for(int i = 0; i<[self.currentPerson.availabilitiesArray count]; i++){
                Interval *interval = (Interval *)self.schedule.intervalDataByOverallRow[i];
                if([self.currentPerson.availabilitiesArray[i] isEqual:@1]) {
                    if(![interval.availablePersons containsObject:self.currentPerson.name]){
                        [interval.availablePersons addObject: self.currentPerson.name];
                    }
                }
                if([self.currentPerson.assignmentsArray[i] isEqual:@1]) {
                    if(![interval.assignedPersons containsObject:self.currentPerson.name]){
                        [interval.assignedPersons addObject:self.currentPerson.name];
                    }
                }
            }
        }

       
    }
}


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.assignedOrAvailableLabel.text isEqual:@""]){
        
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        
        self.updatedAvailabilitiesArray[indexPath.row] = @1;
        
        cell.assignedOrAvailableLabel.text = @"(Available)";
        cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        
        }
    else {
        self.updatedAvailabilitiesArray[indexPath.row] = @0;
        
        cell.assignedOrAvailableLabel.text = @"";
        cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.assignedOrAvailableLabel.textColor = [UIColor redColor];
        
    }
    
   [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}

#pragma mark - Navigation Bar Editing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    // overriding this method means we can attach custom functions to the button
    [super setEditing:editing animated:animated];
    
    // attaching custom actions here
    if (editing) {
        // we're in edit mode
        [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:animated];
        self.tableView.allowsSelection = YES;
        
    } else {
        // we're not in edit mode
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
        self.tableView.allowsSelection = NO;
        
        
    }
}

-(void)cancelButtonPressed
{
    //do cancel button things
    
    //change nav bar
    [self setEditing:false animated:YES];
}


@end
