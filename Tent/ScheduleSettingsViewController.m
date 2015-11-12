//
//  ScheduleSettingsViewController.m
//  Tent
//
//  Created by Jeremy on 10/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "ScheduleSettingsViewController.h"
#import "MySettingsTableViewCell.h"
#import "Constants.h"

@interface ScheduleSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ScheduleSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    /*
        if user is admin
            display edit button in top right
     
     */

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /*
        if PFUser is admin
            then return an extra cell (admin tools). or have this be brought up by a diff bar button item
     */

    return self.settings.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == self.settings.count) return 1; //Admin tools
    NSDictionary *sectionDict = [self.settings objectForKey:[NSNumber numberWithInteger:section]];
    NSArray *sectionData = [sectionDict objectForKey:@"sectionData"];
    return [sectionData count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(section == self.settings.count) return @"Admin";
    NSDictionary *sectionDict = [self.settings objectForKey:[NSNumber numberWithInteger:section]];
    return [sectionDict objectForKey:@"sectionHeader"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == self.settings.count){
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"adminCell"];
        
        
        return cell;
    }else{
        MySettingsTableViewCell *cell = (MySettingsTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
        
        //change use json serializer
        
        NSDictionary *sectionDict = [self.settings objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSArray *sectionData = [sectionDict objectForKey:@"sectionData"];
        NSDictionary *settingData = sectionData[indexPath.row];
        cell.settingNameLabel.text = [settingData objectForKey:@"title"];
        
        if([[settingData objectForKey:@"value"] isKindOfClass:[NSDate class]]){
             cell.settingValueLabel.text = [Constants formatDateAndTime:[settingData objectForKey:@"value"] withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        }else{
             cell.settingValueLabel.text = [settingData objectForKey:@"value"];
        }
        
    
    
    return cell;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
