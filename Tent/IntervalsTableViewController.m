//
//  IntervalsTableViewController.m
//  Tent
//
//  Created by Shrek on 7/30/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "IntervalsTableViewController.h"
#import "PersonsInIntervalViewController.h"
#import "Interval.h"
#import "Constants.h"
@interface IntervalsTableViewController ()
@property (nonatomic) BOOL firstTimeAppearing;
@end

@implementation IntervalsTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleChanged:) name:kNotificationNameScheduleChanged object:nil];
    self.firstTimeAppearing = YES;
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}
-(void)scheduleChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if(!(notification.object == self)){
        Schedule *schedule = userInfo[kUserInfoLocalScheduleKey];
        //update data
        self.schedule = schedule;
        //no need to update UI
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.firstTimeAppearing){
        NSInteger overallRow = [PersonsInIntervalViewController findCurrentTimeIntervalIndexForSchedule:self.schedule];
        if(overallRow < 0) return; //schedule hasn't started or is over
        NSIndexPath *indexPath = [Constants indexPathForOverallRow:overallRow tableView:self.tableView];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.firstTimeAppearing = NO;
    }
    
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
    //return [self.schedule.intervalArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Interval Cell" forIndexPath:indexPath];
    
    //Configure the cell...
    NSMutableDictionary *sectionData = [self.schedule.intervalDataBySection objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    NSUInteger index = [sectionData[@"intervalStartIndex"] integerValue] + indexPath.row;

    Interval *interval = self.schedule.intervalDataByOverallRow[index];
    cell.textLabel.text = interval.timeString;
    

    
    
    return cell;
}


-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue destinationViewController] isKindOfClass:[PersonsInIntervalViewController class]]){
        PersonsInIntervalViewController *piivc = (PersonsInIntervalViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        //need to either store intervalArray data in format that corresponds to section:data. or store total number of rows per section in this class, calculate overall row number each time
        //i'll do calculation for now
        NSUInteger overallRow = [Constants overallRowForIndexPath:indexPath tableView:self.tableView];
        
        
        //TODO: subclass and make it different for Persons vs nowPersons
        Interval *interval = self.schedule.intervalDataByOverallRow[overallRow];
        piivc.availablePersonsArray = interval.availablePersons;
        piivc.assignedPersonsArray = interval.assignedPersons;
        piivc.requiredPersons = self.schedule.requiredPersonsPerInterval;
        
        /*
        NSArray *intervalData = [self.schedule.intervalsDisplayData objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSString *day = intervalData[0];
        NSArray *intervalArray = intervalData[1];
        NSString *time = intervalArray[indexPath.row];
         */
        
        
        piivc.dateTimeText = [self.schedule dateTimeStringForIndexPath:indexPath];
        piivc.navigationItem.title = @"Time Slot";
        
        //do i have to set piivc.displayCurrent to false?


    }
}


@end
