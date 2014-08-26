//
//  IntervalsTableViewController.m
//  Tent
//
//  Created by Shrek on 7/30/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "IntervalsTableViewController.h"
#import "PersonsInIntervalTableViewController.h"
#import "Interval.h"

@interface IntervalsTableViewController ()

@end

@implementation IntervalsTableViewController

-(NSMutableArray *)intervalArray
{
    if(!_intervalArray)_intervalArray = [[NSMutableArray alloc]init];
    return _intervalArray;
}

- (NSArray *)hourIntervalsDisplayArray //make this a class method
{
  
    if(!_hourIntervalsDisplayArray)_hourIntervalsDisplayArray = [[NSArray alloc]init];
    return _hourIntervalsDisplayArray;
}

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
    return [self.intervalArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Interval Cell" forIndexPath:indexPath];
    
    //Configure the cell...
    NSString *interval = self.hourIntervalsDisplayArray[indexPath.row];
    
    cell.textLabel.text = interval;
    

    
    
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue destinationViewController] isKindOfClass:[PersonsInIntervalTableViewController class]]){
        PersonsInIntervalTableViewController *piitvc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Interval *interval = self.intervalArray[indexPath.row];
        piitvc.availablePersonsArray = interval.availablePersons;
        piitvc.assignedPersonsArray = interval.assignedPersons;
        
        
        piitvc.navigationItem.title = self.hourIntervalsDisplayArray[indexPath.row];
        //NSLog(@"AvailablePersons: %@", interval.availablePersons);
        //NSLog(@"AssignedPersons: %@", interval.assignedPersons);

    }
}


@end
