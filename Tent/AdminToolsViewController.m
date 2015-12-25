//
//  AdminToolsViewController.m
//  Tent
//
//  Created by Jeremy on 12/24/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "AdminToolsViewController.h"
#import "Constants.h"
#import "AlgorithmSchedule.h"
@interface AdminToolsViewController ()

@end

@implementation AdminToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)generateAssignmentsButtonPressed:(id)sender {
    NSString *title = @"Generate Assignments";
    NSString *message = self.schedule.assignmentsGenerated ? @"Are you sure you want to generate new schedule assignments? The previous assignments will be lost" : @"Are you sure you want to generate assignments?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self generateAssignments];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:proceedAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)clearAssignmentsButtonPressed:(id)sender {
    NSString *title = @"Clear Assignments";
    if(self.schedule.assignmentsGenerated){
        NSString *message = @"Are you sure you want to clear the schedule assignments that were generated? The availabilities data will not change.";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self clearAssignments];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:proceedAction];
        [self presentViewController:alert animated:YES completion:nil];

    }else{
        NSString *message = @"You have not generated any assignments. Press the 'Generate Assignments' button to automatically generate them.";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}
- (IBAction)clearAvailabilitiesButtonPressed:(id)sender {
    NSString *title = @"Clear Availabilities";
    NSString *message = self.schedule.assignmentsGenerated ? @"Are you sure? Both the assignments and availabilties will be deleted." : @"Are you sure?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self clearAvailabilities];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:proceedAction];
    [self presentViewController:alert animated:YES completion:nil];
        
}

-(void)generateAssignments
{
   // AlgorithmSchedule *algorithmSchedule = [AlgorithmSchedule alloc]init
    self.schedule.assignmentsGenerated = YES;
}

-(void)clearAssignments
{
    //update parse
    //update UI
    //[self.schedule clearAssignments];
    
}

-(void)clearAvailabilities
{
    //update parse
    //update UI
    //[self.schedule clearAvailabilities];
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
