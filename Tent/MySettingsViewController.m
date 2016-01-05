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

#import "PickPersonTableViewController.h"

@interface MySettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *settings;
@property (nonatomic) NSMutableArray *settingValues;


@end

@implementation MySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    PFUser *currentUser = [PFUser currentUser];
    self.settings = @[@"Username", @"Password", @"Email", @"Full Name"];
    self.settingValues = [[NSMutableArray alloc]initWithArray:@[currentUser.username, @"Change Password", currentUser.email, [currentUser objectForKey:kUserPropertyFullName]]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSettingsCell"];
    cell.textLabel.text = self.settings[indexPath.row];
    cell.detailTextLabel.text = self.settingValues[indexPath.row];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self.settings[indexPath.row] isEqualToString:@"Username"]){
        [self changeUsername];
        
    }else if([self.settings[indexPath.row] isEqualToString:@"Password"]){
        [self changePassword];
        
    }else if([self.settings[indexPath.row] isEqualToString:@"Email"]){
        [self changeEmail];
        
    }else if ([self.settings[indexPath.row] isEqualToString:@"Full Name"]){
        [self changeFullName];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

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
                
                // Update table view with new data //Change this to only update desired cell
                self.settingValues[0] = newSettingValue;
                [self.tableView reloadData];
            }else{
                // Display error alert and change local current user back to what it was before change attempt.
                
                NSString *errorMessage;
                if(error.code == 202){
                    errorMessage = [NSString stringWithFormat:@"Username %@ has already been taken. Try again", newSettingValue];
                }else{
                    errorMessage = @"Something went wrong. Check your internet connection and try again.";
                }
                
                currentUser.username = oldSettingValue;
                [self showChangeUsernameAlertWithMessage:errorMessage];

            }
        }];
    }];
    [alert addAction:changeAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)changePassword
{
    [self showChangePasswordAlert];
}
-(void)showChangePasswordAlert
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
                
            }else{
                //show error alert
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Unable to send email." preferredStyle:UIAlertControllerStyleAlert];
                [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:errorAlert animated:YES completion:nil];

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
                
                NSString *errorMessage;
                if(error.code == 125){
                    errorMessage = @"Invalid email address. Try again";
                   
                }else if (error.code == 203){
                    errorMessage = [NSString stringWithFormat:@"Email address %@ has already been taken. Try again", newSettingValue];
                }else{
                    errorMessage = @"Unable to change email. Please try again";
                }
                currentUser.email = oldSettingValue;
                [self showChangeEmailAlertWithMessage:errorMessage];
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
                //Change this to only update desired cell
                self.settingValues[3] = newSettingValue;
                [self.tableView reloadData];
            }else{
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Unable to change name." preferredStyle:UIAlertControllerStyleAlert];
                [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:errorAlert animated:YES completion:nil];
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

- (IBAction)deleteAccountButtonPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Account" message:@"Are you sure? You will be removed from every schedule you joined, and any schedules you created will be deleted." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAccount];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)deleteAccount
{
    //get my schedules
    PFRelation *relation = [[PFUser currentUser] relationForKey:kUserPropertyGroupSchedules];
    PFQuery *query = [relation query];
    [query orderByAscending:@"endDate"];
    [query includeKey:kGroupSchedulePropertyPersonsInGroup];
    [query includeKey:kGroupSchedulePropertyHomeGame];
    [query includeKey:kGroupSchedulePropertyCreatedBy];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", kGroupSchedulePropertyPersonsInGroup, kPersonPropertyAssociatedUser]];
    
    PFUser *currentUser = [PFUser currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedulesForThisUser, NSError *error) {
        if(!error){
            NSMutableArray *schedulesToDelete = [[NSMutableArray alloc]init];
            NSMutableArray *schedulesToRemoveUser = [[NSMutableArray alloc]init];
            for(PFObject *parseSchedule in schedulesForThisUser){
                PFObject *creator = parseSchedule[kGroupSchedulePropertyCreatedBy];
                if([creator.objectId isEqualToString:currentUser.objectId ]){
                    //Delete Schedule
                    [schedulesToDelete addObject:parseSchedule];
                }else{
                    //remove person from schedule
                    NSMutableArray *parsePersons = [[NSMutableArray alloc]initWithArray: parseSchedule[kGroupSchedulePropertyPersonsInGroup]];
                    for(PFObject *parsePerson in parsePersons ){
                        if([[parsePerson[kPersonPropertyAssociatedUser] objectId] isEqualToString:currentUser.objectId]){
                            [parsePersons removeObject:parsePerson];
                            break;
                        }
                    }
                    parseSchedule[kGroupSchedulePropertyPersonsInGroup] = parsePersons;
                    [schedulesToRemoveUser addObject:parseSchedule];
                }
                
            }
            [PFObject saveAllInBackground:schedulesToRemoveUser block:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    [PFObject deleteAllInBackground:schedulesToDelete block:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded){
                            //delete user
                            [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                if(!error){
                                    [self performSegueWithIdentifier:@"userDeletedAccountSegue" sender:self];
                                }
                            }];
                        }
                    }];
                }
            }];

        }
    }];
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}


@end
