//
//  EnterScheduleViewController.m
//  Tent
//
//  Created by Shrek on 8/2/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "EnterScheduleViewController.h"
#import "Schedule.h"
#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalTableViewCell.h"

@interface EnterScheduleViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation EnterScheduleViewController

#pragma mark - Accessor Methods

@synthesize hourIntervals = _hourIntervals;

- (void)setHourIntervals:(NSArray *)hourIntervals
{
    _hourIntervals = hourIntervals;
    [self.tableView reloadData];
}
- (NSArray *)hourIntervals
{
    if(!_hourIntervals) _hourIntervals = @[@"8-9", @"9-10",@"10-11", @"11-12", @"12-1", @"1-2", @"2-3", @"3-4", @"4-5", @"5-6"];
    return _hourIntervals;
}


-(NSMutableArray *)updatedAvailabilitiesArray
{
    
    
    if(!_updatedAvailabilitiesArray){ _updatedAvailabilitiesArray = [[NSMutableArray alloc]initWithArray:self.currentPerson.availabilitiesArray];
        
    }
    
    return _updatedAvailabilitiesArray;
}


#pragma mark - ViewControllerLifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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
    return [self.hourIntervals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Hour Interval Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *hour = self.hourIntervals[indexPath.row];
    cell.textLabel.text = hour;
    
    if([self.currentPerson.availabilitiesArray[indexPath.row] isEqual:@1]) {
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        NSLog(@"Test %d", indexPath.row);
        cell.assignedOrAvailableLabel.text = @"(Available)";
        
    }
    else cell.accessoryType =UITableViewCellAccessoryNone;
    if([self.currentPerson.assignmentsArray count]>0){
        if([self.currentPerson.assignmentsArray[indexPath.row] isEqual:@1]){
            
            //[cell setSelected:YES animated:YES];
            //[cell setSelected:YES];
            // cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            //[cell setBackgroundColor:[UIColor colorWithHue:0.4 saturation:1.0 brightness:0.5 alpha:1.0]];
            
            // cell.assignedOrAvailableLabel.text = @"(Assigned)";
            [cell setBackgroundColor:[UIColor greenColor]];
            
            [cell setOpaque:NO];
            
            
            
            NSLog(@"Test %d", indexPath.row);
        }
    }
    [cell bringSubviewToFront:cell.assignedOrAvailableLabel];
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //NSLog(@"Sender class: %@", [sender class]);
    
    
    if(sender!=self.doneButton) return; //cancel button
    else{ //doneButton
        
        //change person's availabilities array (andupdate to Parse)
        self.currentPerson.availabilitiesArray = self.updatedAvailabilitiesArray;
        PFQuery *query = [PFQuery queryWithClassName:@"Person"];
        [query whereKey:@"index" equalTo:[NSNumber numberWithInt:self.currentPerson.indexOfPerson]];
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
        
        //update availabilities schedule (maybe chance self.currentperson.availabilitiesArray to be an array arrays and save that to Parse
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Schedule"];
        [query2 whereKey:@"type" equalTo:@"availabilities"];
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
        
        
        
       
    }
}*/


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType!=UITableViewCellAccessoryCheckmark){
        //Change checkmark
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        cell.assignedOrAvailableLabel.text = @"(Available)";
        self.updatedAvailabilitiesArray[indexPath.row] = @1;
        
        
        
        NSLog(@"Person: %d array: %@ updateArray: %@", self.currentPerson.indexOfPerson, self.currentPerson.availabilitiesArray, self.updatedAvailabilitiesArray);
        
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.updatedAvailabilitiesArray[indexPath.row] = @0;
        cell.assignedOrAvailableLabel.text = @"";
    }
    
    
}

@end
