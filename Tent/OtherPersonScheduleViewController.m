//
//  OtherPersonScheduleViewController.m
//  Tent
//
//  Created by Jeremy on 1/5/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import "OtherPersonScheduleViewController.h"

#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalTableViewCell.h"
#import "Interval.h"
#import "Constants.h"
#import "PersonsInIntervalViewController.h"
#import "StatsViewController.h"

@interface OtherPersonScheduleViewController ()


@end

@implementation OtherPersonScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.allowsSelection = NO;
    self.navigationItem.leftBarButtonItem = nil;
    
    if(self.canEdit){
        [self changeNavBarToShowEditButton];
    }else{
    }
    
    if([self.schedule.startDate timeIntervalSinceNow] < 0 && [self.schedule.endDate timeIntervalSinceNow] > 0){
        [self scrollToCurrentInterval];
        //maybe keep track off last offset and scroll to that one instead
        
    }
    

    [self makeAvailableForAll];
}

//Testing
-(void)makeAvailableForAll
{
    for(int i = 0; i<self.updatedAvailabilitiesArray.count;i++){
        self.updatedAvailabilitiesArray[i] = @1;
    }
    [self saveEdits];

}


-(BOOL)isMe{
    return [self.currentPerson.user.objectId isEqualToString:[[PFUser currentUser] objectId]];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    // overriding this method means we can attach custom functions to the button
    // this is the default action method for self.editButtonItem
    [super setEditing:editing animated:animated];
    
    // attaching custom actions here
    if (editing) {
        // we're in edit mode
        //[self.navigationItem setLeftBarButtonItem:self.cancelButton animated:animated];
        //self.tableView.allowsSelection = YES; //unnecessary because i set this in storyboard
        
    } else {
        // we're not in edit mode
        //[self.navigationItem setLeftBarButtonItem:nil animated:animated];
        //self.tableView.allowsSelection = NO;
        
        
    }
}
-(void)editButtonPressed
{
    if(self.schedule.assignmentsGenerated){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Assignments Already Generated" message:@"Are you sure you want to edit?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self changeToEditMode];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        [self changeToEditMode];
    }
}
-(void)changeToEditMode
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];;
    [self.tableView setEditing:true animated:YES]; //true vs yes?
}
-(void)doneButtonPressed
{
    //do done button things
    [self saveEdits];
    [self changeNavBarToShowEditButton];
    [self.tableView setEditing:false animated:YES];
}
-(void)cancelButtonPressed
{
    //do cancel button things
    self.updatedIntervalDataByOverallRowArray = nil;//[self.schedule.intervalDataByOverallRow copy];
    self.updatedAvailabilitiesArray = nil;//[self.currentPerson.assignmentsArray copy];
    [self.tableView reloadData];
    [self changeNavBarToShowEditButton];
    [self.tableView setEditing:false animated:YES];
}
-(void)changeNavBarToShowEditButton
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.navigationItem.leftBarButtonItem = nil;
}


@end
