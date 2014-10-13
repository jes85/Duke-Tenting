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


    }
}


@end
