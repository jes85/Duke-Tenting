//
//  EnterScheduleTableViewController.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "EnterScheduleTableViewController.h"
#import "Schedule.h"
#import "PickPersonTableViewController.h"
#import "Person.h"

@interface EnterScheduleTableViewController ()

@end

@implementation EnterScheduleTableViewController

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Hour Interval Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *hour = self.hourIntervals[indexPath.row];
    cell.textLabel.text = hour;
    
    if([self.currentPerson.availabilitiesArray[indexPath.row] isEqual:@1]) cell.accessoryType =UITableViewCellAccessoryCheckmark;
    else cell.accessoryType =UITableViewCellAccessoryNone;
    
    
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //NSLog(@"Sender class: %@", [sender class]);
    
    
    if(sender!=self.doneButton) return; //cancel button
    else{ //doneButton
        
        //change person's availabilities array (update to Parse later)
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
                [object saveInBackground];
            }
        }];
        
        
        //this part is in unWindToList
        /*PickPersonTableViewController *destination = [segue destinationViewController];
        [destination.people insertObject:self.currentPerson atIndex:self.currentPerson.indexOfPerson];
        [destination.people removeObjectAtIndex:self.currentPerson.indexOfPerson+1];*/
    }
}


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType!=UITableViewCellAccessoryCheckmark){
        //Change checkmark
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        self.updatedAvailabilitiesArray[indexPath.row] = @1;
        
        
        
        NSLog(@"Person: %d array: %@ updateArray: %@", self.currentPerson.indexOfPerson, self.currentPerson.availabilitiesArray, self.updatedAvailabilitiesArray);
        
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.updatedAvailabilitiesArray[indexPath.row] = @0;
    }
    
    
}

@end
