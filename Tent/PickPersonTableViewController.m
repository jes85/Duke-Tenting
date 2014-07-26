//
//  PickPersonTableViewController.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "PickPersonTableViewController.h"
#import "EnterScheduleTableViewController.h"
#import "Person.h"
#import "Schedule.h"


@interface PickPersonTableViewController ()

@end

@implementation PickPersonTableViewController

@synthesize people = _people;

- (void)setPeople:(NSMutableArray *)people
{
    _people = people;
    [self.tableView reloadData];
}
- (NSMutableArray *)people
{
    if(!_people) _people = [self createPeopleArray];
    return _people;
}

-(NSMutableArray *)createPeopleArray
{
    Schedule *schedule = [[Schedule alloc]init];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(int p = 0;p<schedule.numPeople;p++){
        Person *person = [[Person alloc]init];
        person.indexOfPerson = p;
        person.name = [NSString stringWithFormat:@"Person %d", p];
        for(int i = 0; i<schedule.numIntervals;i++){
            [person.availabilitiesArray addObject:@0];
             
        }
        
        [array addObject:person];
        PFObject *personObject = [PFObject objectWithClassName:@"Person"];
        NSNumber *index = [NSNumber numberWithInt:person.indexOfPerson];    
        personObject[@"index"] = index;
        personObject[@"availabilitiesArray"] = person.availabilitiesArray;
        [personObject saveInBackground];
    }
    
    return array;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.people count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Person *person = self.people[indexPath.row];
    NSString *personName = person.name;
    cell.textLabel.text = personName;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    //Check id using introspection
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if(indexPath){
            //More checking
            if([segue.identifier isEqualToString:@"Person To Hour Interval"]){
                
                if([segue.destinationViewController  isKindOfClass:[EnterScheduleTableViewController class]]){
                    
                    Person *person = self.people[indexPath.row];
                   
                    EnterScheduleTableViewController *estvc = [segue destinationViewController];
                    estvc.currentPerson = person;
                   // NSLog(@"Person: %d array: %@", estvc.currentPerson.indexOfPerson, estvc.currentPerson.availabilitiesArray);
                    
                }
            }
        }
    }else{
        NSLog(@"Error");
    }
}



//Save data
-(IBAction)unWindToList:(UIStoryboardSegue *)segue
{
    
    EnterScheduleTableViewController *source = [segue sourceViewController];
    Person *person = source.currentPerson;
    //NSMutableArray *updatedAvailabilitiesArray = person.availabilitiesArray;
    [self.people removeObjectAtIndex:person.indexOfPerson];
    [self.people insertObject:person atIndex:person.indexOfPerson];
    
}


@end
