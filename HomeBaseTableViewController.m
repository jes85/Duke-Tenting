//
//  HomeBaseTableViewController.m
//  Tent
//
//  Created by Shrek on 7/30/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "HomeBaseTableViewController.h"
#import "PickPersonTableViewController.h"
#import "Person.h"
#import "IntervalsTableViewController.h"

@interface HomeBaseTableViewController ()

@property (nonatomic)NSMutableArray *people;
@property (nonatomic) NSMutableArray *intervalArray;
@end

@implementation HomeBaseTableViewController



#pragma mark - Property setup
-(NSMutableArray *)people{
    if(!_people)_people = [[NSMutableArray alloc]init];
    //NSLog(@"Test %@",  _people);

    return _people;
}
-(NSMutableArray *)intervalArray
{
    //if(!_intervalArray)_intervalArray = [[NSMutableArray alloc]init];
    return _intervalArray;
}

#pragma mark - init
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
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    //__block NSMutableArray *peopleArray;// = [[NSMutableArray alloc]init];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if(!objects){
             NSLog(@"Find failed");
         }else if ([objects count]<1){
             NSLog(@"No objects in Parse");
         }
         else{
             //the find succeeded
             NSLog(@"Find succeeded %d", [objects count]);
             //for(Person *person in objects){
             //  [array addObject:person];
             //}
             //
             //get schedules and then add it
             for(PFObject *object in objects){
                 NSString *name = object[@"name"];
                 
                 NSUInteger index = [object[@"index"] intValue];
                 
                 NSMutableArray *availableArray = object[@"availabilitiesArray"];
               
                 Person *person = [[Person alloc]initWithName:name index:index availabilitiesArray:availableArray];
                 if(object[@"assignmentsArray"])
                     person.assignmentsArray = object[@"assignmentsArray"];
                 //NSLog(@"Assignments Array %@", person.assignmentsArray);
                 [self.people addObject:person];
                 
                 
                 if(!self.intervalArray){self.intervalArray = [[NSMutableArray alloc] initWithCapacity:[availableArray count]];
                 for(int i = 0;i<[availableArray count]; i++){
                     NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                     [self.intervalArray addObject:tempArray];
                 }
                 }
                 for(int i = 0; i<[availableArray count]; i++){
                     if([availableArray[i] isEqual:@1]){
                         //update vc's intervalArray
                         /*NSMutableArray *a = self.intervalArray[i];
                         [a addObject:person.name];
                         [self.intervalArray removeObjectAtIndex:i];
                         [self.intervalArray insertObject:a atIndex: i];*/
                         [self.intervalArray[i] addObject:person];//person.name
                         //NSLog(@"Test: %@", self.intervalArray);
                     }
                 }
                 
             }
            // NSLog(@"Test: %@", self.intervalArray);
             
             //peopleArray = [[NSMutableArray alloc]initWithArray:objects];
             

             //self.people = peopleArray;
             

         }
    }];
   
    

    
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
    return 2;
}


/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Interval Cell" forIndexPath:indexPath];
    
    //Configure the cell...
    NSString *interval = self.possibleIntervals[indexPath.row];
    
    cell.textLabel.text = interval;
    
    return cell;

    
    return cell;
}*/


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
    
    //UINavigationController *nc = [segue destinationViewController];
    //PickPersonTableViewController *pptvc = (PickPersonTableViewController *)nc.topViewController;
    
    if([[segue destinationViewController] isKindOfClass:[PickPersonTableViewController class]]){
        
        PickPersonTableViewController *pptvc = [segue destinationViewController];
        if([self.people count]>0) pptvc.people = self.people;
        NSLog(@"array: %@", self.people);
    }
    else if([[segue destinationViewController] isKindOfClass:[IntervalsTableViewController class]]){
        IntervalsTableViewController *itvc = [segue destinationViewController];
        itvc.intervalArray = self.intervalArray;
        NSLog(@"intervalArray %@", self.intervalArray);
    }
}


@end
