//
//  EnterScheduleTableViewController.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "EnterScheduleTableViewController.h"
#import "Schedule.h"
#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalTableViewCell.h"
#import "Interval.h"

@interface EnterScheduleTableViewController ()
@property(nonatomic, strong) NSMutableArray *updatedAvailabilitiesArray;
@end

@implementation EnterScheduleTableViewController

#pragma mark - Accessor Methods


- (NSArray *)hourIntervalsDisplayArray //make this a class method
{
    if(!_hourIntervalsDisplayArray)_hourIntervalsDisplayArray = [[NSArray alloc]init];
    return _hourIntervalsDisplayArray;
}
-(NSMutableArray *)intervalArray
{
    if(!_intervalArray)_intervalArray = [[NSMutableArray alloc]init];
    return _intervalArray;
}

 -(NSMutableArray *)updatedAvailabilitiesArray
{
   
    
    if(!_updatedAvailabilitiesArray)_updatedAvailabilitiesArray = [[NSMutableArray alloc]initWithArray:self.currentPerson.availabilitiesArray];
    
    
    return _updatedAvailabilitiesArray;
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
   
    return [self.hourIntervalsDisplayArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"     Time                                          Status "; //fix for autolayout
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.currentPerson.assignmentsArray[indexPath.row] isEqual:@1]){
        [cell.contentView setBackgroundColor:[UIColor greenColor]];

    }
     if([self.currentPerson.availabilitiesArray[indexPath.row] isEqual:@1]) {
          [cell.contentView setBackgroundColor:[UIColor blueColor]];
     }
    

}*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Interval Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
   
    NSString *interval = self.hourIntervalsDisplayArray[indexPath.row];
    cell.textLabel.text = interval;
   
    
//cell.imageView addConstraint:<#(NSLayoutConstraint *)#>
    
    if([self.currentPerson.assignmentsArray[indexPath.row] isEqual:@1]){
        
        //[cell setSelected:YES animated:YES];
        //[cell setSelected:YES];
        // cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        //[cell setBackgroundColor:[UIColor colorWithHue:0.4 saturation:1.0 brightness:0.5 alpha:1.0]];
        //cell.accessoryType =UITableViewCellAccessoryCheckmark;
        cell.assignedOrAvailableLabel.text = @"(Assigned)";
        cell.iconImageView.image =[UIImage imageNamed:@"GreenCircle"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:0 green:.3 blue:0 alpha:1.0];
       // cell.assignedOrAvailableLabel.textColor = [UIColor greenColor];
        //[cell.contentView setBackgroundColor:[UIColor greenColor]];
        // [cell setOpaque:NO];
        
        
    }

    else if([self.currentPerson.availabilitiesArray[indexPath.row] isEqual:@1]) {
        //cell.accessoryType =UITableViewCellAccessoryNone;
        cell.assignedOrAvailableLabel.text = @"(Available)";
        cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        //cell.assignedOrAvailableLabel.textColor = [UIColor yellowColor];
        //[cell.contentView setBackgroundColor:[UIColor blueColor]];
        //[cell setOpaque:NO];

        
    }
    else {
        //cell.accessoryType =UITableViewCellAccessoryNone;
        
        
        cell.assignedOrAvailableLabel.text = @"";
        cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.assignedOrAvailableLabel.textColor = [UIColor redColor];
    }
    
    
    
    
    [cell.contentView addSubview:cell.assignedOrAvailableLabel]; //I don't think I should have to do this because I did it in a storyboards. I think I didn't connect the outlets correctly
    [cell.contentView addSubview:cell.iconImageView];
    
    return cell;
}


#pragma mark - Navigation

 //In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //NSLog(@"Sender class: %@", [sender class]);
    
    
    if(sender!=self.doneButton) return; //cancel button
    else{ //doneButton
        
        //if current person's availabilities array was changed, update it and update on Parse
        if(![self.currentPerson.availabilitiesArray isEqual:self.updatedAvailabilitiesArray]){
        
        //update person's availabilities array (and update to Parse)
       self.currentPerson.availabilitiesArray = self.updatedAvailabilitiesArray;
#warning Fix this
            //update schedule offline
            PickPersonTableViewController *pptvc = [segue destinationViewController];
            pptvc.schedule.availabilitiesSchedule[self.currentPerson.indexOfPerson] = self.currentPerson.availabilitiesArray;
        PFQuery *query = [PFQuery queryWithClassName:@"Person"];
        [query whereKey:@"scheduleName" equalTo:self.currentPerson.scheduleName];
        [query whereKey:@"index" equalTo:[NSNumber numberWithInteger:self.currentPerson.indexOfPerson]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(!object){
                NSLog(@"Find failed");
            }else{
               //the find succeeded
                NSLog(@"Find succeeded");
                object[@"availabilitiesArray"] = self.currentPerson.availabilitiesArray;
                //object[@"assignmentsArray"] = self.currentPerson.assignmentsArray;
                [object saveInBackground];
            }
        }];
        
        //update availabilities schedule (maybe change self.currentperson.availabilitiesArray to be an array arrays and save that to Parse
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Schedule"];
        [query2 whereKey:@"name" equalTo:self.currentPerson.scheduleName];
        [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(!object){
                NSLog(@"Find failed");
            }else{
                //the find succeeded
                NSLog(@"Find succeeded");
                NSMutableArray *array = object[@"availabilitiesSchedule"] ;
                array[self.currentPerson.indexOfPerson]= self.currentPerson.availabilitiesArray;
                object[@"availabilitiesSchedule"] =array;
                
                [object saveInBackground];
            }
        }];
        }
        
        //update intervlas
        for(int i = 0; i<[self.currentPerson.availabilitiesArray count]; i++){
            Interval *interval = (Interval *)self.intervalArray[i];
            if([self.currentPerson.availabilitiesArray[i] isEqual:@1]) {
                [interval.availablePersons addObject: self.currentPerson];
            }
            if([self.currentPerson.assignmentsArray[i] isEqual:@1]) {
                [interval.assignedPersons addObject:self.currentPerson];
            }
        }

        //this part is in unWindToList (maybe change that)
        /*PickPersonTableViewController *destination = [segue destinationViewController];
        [destination.people insertObject:self.currentPerson atIndex:self.currentPerson.indexOfPerson];
        [destination.people removeObjectAtIndex:self.currentPerson.indexOfPerson+1];*/
    }
}


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    IntervalTableViewCell *cell = (IntervalTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.assignedOrAvailableLabel.text isEqual:@""]){
        //Change checkmark
        //Save data in updatedAvailabilities array (will save/ignore this in Done/Cancel button action later)
        
        self.updatedAvailabilitiesArray[indexPath.row] = @1;
        
        cell.assignedOrAvailableLabel.text = @"(Available)";
        cell.iconImageView.image =[UIImage imageNamed:@"YellowSquare"];
        cell.assignedOrAvailableLabel.textColor = [UIColor colorWithRed:.7 green:.5 blue:0 alpha:1.0];
        
        
        //old stuff
        //cell.accessoryType =UITableViewCellAccessoryCheckmark;
        //[cell.contentView setBackgroundColor:[UIColor blueColor]];
        //[cell setOpaque:NO];

        
        
        
        
        
        
        
        
        //NSLog(@"Person: %d array: %@ updateArray: %@", self.currentPerson.indexOfPerson, self.currentPerson.availabilitiesArray, self.updatedAvailabilitiesArray);
        
    }
    else {
        self.updatedAvailabilitiesArray[indexPath.row] = @0;
        
        cell.assignedOrAvailableLabel.text = @"";
        cell.iconImageView.image =[UIImage imageNamed:@"RedX"];
        cell.assignedOrAvailableLabel.textColor = [UIColor redColor];
        
        
        //old stuff
        //cell.accessoryType = UITableViewCellAccessoryNone;
        //[cell.contentView setBackgroundColor:[UIColor whiteColor]];
        //[cell setOpaque:NO];
    }
    
   [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}




@end
