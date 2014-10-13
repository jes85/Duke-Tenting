//
//  PersonsInIntervalTableViewController.m
//  Tent
//
//  Created by Shrek on 8/5/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "PersonsInIntervalTableViewController.h"
#import "Person.h"

@interface PersonsInIntervalTableViewController ()

@end

@implementation PersonsInIntervalTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section==0){
        if([self.assignedPersonsArray count]<1) return 1;
        return [self.assignedPersonsArray count];
    }
    if(section==1){
        if([self.availablePersonsArray count]<1) return 1;
        return [self.availablePersonsArray count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"Persons Assigned";
    if(section == 1)
        return @"Persons Available";
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    
    // Configure the cell...
   
    
    //Assigned Persons
    if(indexPath.section == 0){
        
        // Display NONE if no one is assigned
        if([self.assignedPersonsArray count]<1) {
            cell.textLabel.text = @"None";
            return cell;
        }
        
        
        // Display person's name
        NSString *personName = self.assignedPersonsArray[indexPath.row];
        cell.textLabel.text = personName;
    }
  
    
    // Available Persons
    if(indexPath.section == 1){
        
        // Display NONE if no one is available
        if([self.availablePersonsArray count]<1) {
            cell.textLabel.text = @"None";
            return cell;
        }
        
        // Display person's name
        NSString *personName = self.availablePersonsArray[indexPath.row];
        cell.textLabel.text = personName;
    }
      return cell;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
