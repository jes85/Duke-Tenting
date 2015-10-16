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

-(void)viewDidLoad
{
    [super viewDidLoad];
   
}


#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sectionData = [self.schedule.intervalsDisplayData objectForKey:[NSNumber numberWithInteger:section]];
    return sectionData[0];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return self.schedule.intervalsDisplayData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    NSArray *intervalDisplayDataForSection =[self.schedule.intervalsDisplayData objectForKey:[NSNumber numberWithInteger:section]];
    NSArray *intervalDisplayArrayForSection = intervalDisplayDataForSection[1];
                                            
    return intervalDisplayArrayForSection.count;
    //return [self.schedule.intervalArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Interval Cell" forIndexPath:indexPath];
    
    //Configure the cell...
    //NSString *interval = self.schedule.hourIntervalsDisplayArray[indexPath.row];
    NSArray *sectionData = [self.schedule.intervalsDisplayData objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    NSArray *intervalDisplayArray = sectionData[1];

    
    cell.textLabel.text = intervalDisplayArray[indexPath.row];
    

    
    
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
        
        //need to either store intervalArray data in format that corresponds to section:data. or store total number of rows per section in this class, calculate overall row number each time
        //i'll do calculation for now
        NSUInteger overallRow = indexPath.row;
        for(int i = 0; i<indexPath.section; i++){
            overallRow += [self.tableView numberOfRowsInSection:i];
        }
        Interval *interval = self.schedule.intervalArray[overallRow];
        piitvc.availablePersonsArray = interval.availablePersons;
        piitvc.assignedPersonsArray = interval.assignedPersons;
        
        
        
        NSArray *intervalData = [self.schedule.intervalsDisplayData objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSString *day = intervalData[0];
        NSArray *intervalArray = intervalData[1];
        NSString *time = intervalArray[indexPath.row];
        piitvc.navigationItem.title = [[day stringByAppendingString:@" "] stringByAppendingString:time];


    }
}


@end
