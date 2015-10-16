//
//  MySettingsViewController.m
//  Tent
//
//  Created by Jeremy on 10/16/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MySettingsViewController.h"
#import "MySettingsTableViewCell.h"

@interface MySettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *settings;
@property (nonatomic) NSArray *settingValues;

@end

@implementation MySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    PFUser *currentUser = [PFUser currentUser];

    self.settings = @[@"Username:", @"Password:", @"Email:", @"Full Name:"];
    self.settingValues = @[currentUser.username, @"Password", currentUser.email, @"Full Name"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settings.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MySettingsTableViewCell *cell = (MySettingsTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    
    
    cell.settingNameLabel.text = self.settings[indexPath.row];
    cell.settingValueLabel.text = self.settingValues[indexPath.row];
    
    return cell;
}
- (IBAction)logOutButtonPressed:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"closeSettingsSegue" sender:self];
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
