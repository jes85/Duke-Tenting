//
//  MySettingsViewController.m
//  Tent
//
//  Created by Jeremy on 10/16/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "MySettingsViewController.h"
#import "MySettingsTableViewCell.h"
#import "Constants.h"

@interface MySettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *settings;
@property (nonatomic) NSMutableArray *settingValues;

@end

@implementation MySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    PFUser *currentUser = [PFUser currentUser];

    self.settings = @[@"Username", @"Password", @"Email", @"Full Name"];
    self.settingValues = [[NSMutableArray alloc]initWithArray:@[currentUser.username, @"Change Password", currentUser.email, [currentUser objectForKey:kUserPropertyFullName]]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.settings[indexPath.row] isEqualToString:@"Username"]){
        [self changeUsername];
        
    }else if([self.settings[indexPath.row] isEqualToString:@"Password"]){
        [self changePassword];
        
    }else if([self.settings[indexPath.row] isEqualToString:@"Email"]){
        [self changeEmail];
        
    }else if ([self.settings[indexPath.row] isEqualToString:@"Full Name"]){
        [self changeFullName];
    }
}
-(void)changeUsername
{
    [self showChangeUsernameAlertWithMessage:@"Enter a new username."];
}
-(void)showChangeUsernameAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [self changeSettingAlertWithTitle:@"Change Username" message:message placeholder:[[PFUser currentUser] username]];
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        PFUser *currentUser = [PFUser currentUser];
        NSString *oldSettingValue = currentUser.username;
        NSString *newSettingValue = textField.text;
        //Update current user on parse
        currentUser.username = newSettingValue;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                self.settingValues[0] = newSettingValue;
                
                //Change this to only update desired cell
                [self.tableView reloadData];
            }else{
                if(error.code == 202){
                    currentUser.username = oldSettingValue;
                    [self showChangeUsernameAlertWithMessage:[NSString stringWithFormat:@"Username %@ has already been taken. Try again", newSettingValue]];
                }
            }
        }];
    }];
    [alert addAction:changeAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)changePassword
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Password" message:@"We will send you an email with a link to change your password." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    UIAlertAction *sendAction = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [PFUser requestPasswordResetForEmailInBackground:[[PFUser currentUser] email] block:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                //show success alert
                UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Check your email." preferredStyle:UIAlertControllerStyleAlert];
                [successAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:successAlert animated:YES completion:nil];
                
            }
        }];

    }];
    [alert addAction:sendAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    }
-(void)changeEmail
{
    [self showChangeEmailAlertWithMessage:@"Enter a new email."];
}
-(void)showChangeEmailAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [self changeSettingAlertWithTitle:@"Change Email" message:message placeholder:[[PFUser currentUser] email]];
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        PFUser *currentUser = [PFUser currentUser];

        NSString *oldSettingValue = currentUser.email;
        NSString *newSettingValue = textField.text;
        //Update current user on parse
        currentUser.email = newSettingValue;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                //Change this to only update desired cell
                self.settingValues[2] = newSettingValue;
                [self.tableView reloadData];
            }else{
                if(error.code == 125){
                    //alert.message = @"Invalid email address. Try again";
                    currentUser.email = oldSettingValue;
                    [self showChangeEmailAlertWithMessage:@"Invalid email address. Try again"];
                }else if (error.code == 203){
                    //alert.message = [NSString stringWithFormat:@"Email address %@ has already been taken. Try again", newSettingValue];
                    currentUser.email = oldSettingValue;
                    [self showChangeEmailAlertWithMessage:[NSString stringWithFormat:@"Email address %@ has already been taken. Try again", newSettingValue]];
                    
                }
            }
        }];
    }];
    [alert addAction:changeAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)changeFullName
{
    UIAlertController *alert = [self changeSettingAlertWithTitle:@"Change Name" message:@"Enter a new name." placeholder:[[PFUser currentUser] objectForKey:kUserPropertyFullName]];
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *newSettingValue = textField.text;
        //Update current user on parse
        PFUser *currentUser = [PFUser currentUser];
        [currentUser setValue:newSettingValue forKey:kUserPropertyFullName];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                self.settingValues[3] = newSettingValue;
                //Change this to only update desired cell
                [self.tableView reloadData];
            }
        }];
    }];
    [alert addAction:changeAction];
    [self presentViewController:alert animated:YES completion:nil];

}
-(UIAlertController *)changeSettingAlertWithTitle:(NSString *)title message:(NSString *)message placeholder:(NSString *)placeholder
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = placeholder;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    return alert;
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
