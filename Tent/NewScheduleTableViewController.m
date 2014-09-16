//
//  NewScheduleTableViewController.m
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "NewScheduleTableViewController.h"
#import "Schedule.h"
#import "HomeGame.h"
#import "HomeGamesTableViewCell.h"
#import "JoinScheduleTableViewController.h"
#import "AddSchedulesTableViewController.h"
#import <Parse/Parse.h>


#define kPersonClassName    @"Person"
#define kScheduleClassName  @"Schedule"

#define kSchedulePropertyName                   @"name"
#define kSchedulePropertyStartDate              @"startDate"
#define kSchedulePropertyEndDate                @"endDate"
#define kSchedulePropertyAvailabilitiesSchedule @"availabilitiesSchedule"
#define kSchedulePropertyAssignmentsSchedule    @"assignmentsSchedule"
#define kSchedulePropertyNumHourIntervals       @"numHourIntervals"
#define kSchedulePropertyPrivacy                @"privacy"
#define kSchedulePropertyPassword               @"password"
#define kSchedulePropertyHomeGameIndex          @"homeGameIndex"

#define kPrivacyValuePrivate                    @"private"
#define kPrivacyValuePublic                     @"public"

#define kUserPropertySchedulesList              @"schedulesList"

static const NSUInteger numHomeGames = 20;

@interface NewScheduleTableViewController ()
@property (nonatomic) NSArray *homeGames;

@property (nonatomic) NSUInteger selectedIndexPathRow;
@end

@implementation NewScheduleTableViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *homeGamesTemp = [[NSMutableArray alloc]initWithCapacity:numHomeGames];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setYear:2014];
    
    
    //Countdown To Craziness Friday Oct. 18 8 pm
    [components setMonth: 10];
    [components setDay:18];
    [components setHour:20];
    [components setWeekday:6];
    NSDate *gameTime = [calendar dateFromComponents:components];
    
    NSString *opponent = @"Countdown To Craziness";
    BOOL isExhibition = NO;
    
    HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame ];
    
    //Bowie State (Exhibition) Saturday Oct. 26 1 pm
    [components setMonth: 10];
    [components setDay:26];
    [components setHour:13];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Bowie State";
    isExhibition = YES;
    
    HomeGame *homeGame1 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame1 ];
    
    
    //Drury (Exhibition) Saturday Nov. 2, 1 pm
    [components setMonth: 11];
    [components setDay:2];
    [components setHour:13];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Drury";
    isExhibition = YES;
    
    HomeGame *homeGame2 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame2 ];

    //Davidson Friday Nov. 8, 7pm
    [components setMonth: 11];
    [components setDay:8];
    [components setHour:19];
    [components setWeekday:6];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Davidson";
    isExhibition = NO;
    
    HomeGame *homeGame3 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame3 ];

    //Florida Atlantic Friday Nov.15,7 pm
    [components setMonth: 11];
    [components setDay:15];
    [components setHour:19];
    [components setWeekday:6];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Florida Atlantic";
    isExhibition = NO;
    
    HomeGame *homeGame4 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame4 ];

    //UNC Asheville Monday Nov. 18 7pm
    [components setMonth: 11];
    [components setDay:18];
    [components setHour:19];
    [components setWeekday:2];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"UNC Asheville";
    isExhibition = NO;
    
    HomeGame *homeGame5 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame5 ];

    //East Carolina/Norfolk State Tuesday Nov. 19 6pm
    [components setMonth: 11];
    [components setDay:19];
    [components setHour:18];
    [components setWeekday:3];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"East Carolina/Norfolk State";
    isExhibition = NO;
    
    HomeGame *homeGame6 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame6 ];

    //Vermont Sunday Nov. 24 6:30 pm
    [components setMonth: 11];
    [components setDay:24];
    [components setHour:18];
    [components setMinute:30];
    [components setWeekday:1];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Vermont";
    isExhibition = NO;
    
    HomeGame *homeGame7 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame7 ];

    //Michigan Tuesday Dec. 3 9:15 pm
    [components setMonth: 12];
    [components setDay:3];
    [components setHour:21];
    [components setMinute:15];
    [components setWeekday:3];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Michigan";
    isExhibition = NO;
    
    HomeGame *homeGame8 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame8 ];

    //Gardner-Webb Monday Dec. 16 7 pm
    [components setMonth: 12];
    [components setDay:16];
    [components setHour:19];
    [components setWeekday:1];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Gardner-Webb";
    isExhibition = NO;
    
    HomeGame *homeGame9 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame9 ];

    //Eastern Michigan Saturday Dec 28 2pm
    [components setMonth: 12];
    [components setDay:28];
    [components setHour:14];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Eastern Michigan";
    isExhibition = NO;
    
    HomeGame *homeGame10 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame10 ];

    //Georgia Tech Tuesday Jan. 7, 7 pm
    [components setMonth: 1];
    [components setDay:7];
    [components setHour:19];
    [components setYear:2015];
    [components setWeekday:3];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Georgia Tech";
    isExhibition = NO;
    
    HomeGame *homeGame11 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame11 ];

    //Virginia Monday Jan. 13, 7 pm
    [components setMonth: 1];
    [components setDay:13];
    [components setHour:19];
    [components setYear:2015];
    [components setWeekday:1];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Virginia";
    isExhibition = NO;
    
    HomeGame *homeGame12 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame12 ];

    //NC State Saturday Jan 18, 2pm
    [components setMonth: 1];
    [components setDay:18];
    [components setHour:14];
    [components setYear:2015];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"NC State";
    isExhibition = NO;
    
    HomeGame *homeGame13 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame13 ];

    //FLorida State Saturday Jan 25, 12 pm
    [components setMonth: 1];
    [components setDay:25];
    [components setHour:12];
    [components setYear:2015];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Florida State";
    isExhibition = NO;
    
    HomeGame *homeGame14 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame14 ];

    // Wake Forest Tuesday Feb. 4, 9 pm
    [components setMonth: 2];
    [components setDay:4];
    [components setHour:21];
    [components setYear:2015];
    [components setWeekday:3];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Wake Forest";
    isExhibition = NO;
    
    HomeGame *homeGame15 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame15 ];

    //Maryland Saturday Feb 15, 6 pm
    [components setMonth: 2];
    [components setDay:15];
    [components setHour:18];
    [components setYear:2015];
    [components setWeekday:7];
    
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Maryland";
    isExhibition = NO;
    
    HomeGame *homeGame16 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame16 ];

    //Syracuse Saturday Feb. 22, 7pm
    [components setMonth: 2];
    [components setDay:22];
    [components setHour:19];
    [components setYear:2015];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Syracuse";
    isExhibition = NO;
    
    HomeGame *homeGame17 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame17 ];

    //Virginia Tech Tuesday Feb. 25, 7pm
    [components setMonth: 2];
    [components setDay:25];
    [components setHour:19];
    [components setYear:2015];
    [components setWeekday:3];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Virginia Tech";
    isExhibition = NO;
    
    HomeGame *homeGame18 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame18 ];

    //North Carolina Saturday Mar. 8, 9pm
    [components setMonth: 3];
    [components setDay:8];
    [components setHour:21];
    [components setYear:2015];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"North Carolina";
    isExhibition = NO;
    
    HomeGame *homeGame19 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame19 ];

    
    self.homeGames = [homeGamesTemp copy];
    
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
    //return [self.publicSchedules count];
    return [self.homeGames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   HomeGamesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"New Schedule" forIndexPath:indexPath];
    
    // Configure the cell...
    
    HomeGame *homeGame = self.homeGames[indexPath.row];
    
    
    // Opponent name
    NSString *opponentNameLabelText = homeGame.opponentName;
    BOOL isExhibition = homeGame.isExhibition;
    if(isExhibition) opponentNameLabelText = [opponentNameLabelText stringByAppendingString:@" (Exhibition)"];
   

    // Weekday and calendar date
    NSDate *date = homeGame.gameTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *weekday = [[dateFormatter shortWeekdaySymbols][0] stringByAppendingString:@" "];
    NSString *dateLabelText = [weekday stringByAppendingString:[dateFormatter stringFromDate:date]];
    
    // Time
    NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc]init];
    [timeDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *timeLabelText = [timeDateFormatter stringFromDate:date];
    
    
    // Set text of labels
    cell.opponentNameLabel.text = opponentNameLabelText;
    cell.dateLabel.text = dateLabelText;
    cell.weekdayAndTimeLabel.text = timeLabelText;
    
    
    
    /*next view controller
    Schedule *schedule = self.publicSchedules[indexPath.row];
    
    cell.textLabel.text = schedule.name;
    
    if([self.mySchedules containsObject:schedule]) {
        cell.detailTextLabel.text = @"Joined";
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    */
    
    //configure join button
    cell.delegate = self;
    
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

-(void)buttonPressed:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.selectedIndexPathRow = indexPath.row;
    
}

-(NSArray *)getSchedulesAssociatedWithHomeGameIndex:(NSUInteger)homeGameIndex
{
    __block NSMutableArray *schedulesAssociatedWithThisHomeGame = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:kScheduleClassName];
    [query whereKey:kSchedulePropertyHomeGameIndex equalTo:[NSNumber numberWithInteger:homeGameIndex ]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *schedules, NSError *error) {
        if(!schedules){
            NSLog(@"Find failed");
        }else if ([schedules count]<1){
            NSLog(@"No schedules associated with home game index %lu in Parse", (unsigned long)homeGameIndex);
        }else{
            NSLog(@"Find schedules associated with home game index %lu succeeded", (unsigned long)homeGameIndex);
            for(PFObject *schedule in schedules){
                NSString *name = schedule[kSchedulePropertyName];
                NSMutableArray *availabilitiesSchedule = schedule[kSchedulePropertyAvailabilitiesSchedule];
                NSMutableArray *assignmentsSchedule = schedule[kSchedulePropertyAssignmentsSchedule];
                NSDate *startDate = schedule[kSchedulePropertyStartDate];
                NSDate *endDate = schedule[kSchedulePropertyEndDate];
                NSUInteger numHourIntervals = [schedule[kSchedulePropertyNumHourIntervals ] integerValue];
                NSString *privacy = schedule[kSchedulePropertyPrivacy];
                NSString *password = schedule[kSchedulePropertyPassword];
                NSUInteger homeGameIndex = [schedule[kSchedulePropertyHomeGameIndex] integerValue];
                
                Schedule *schedule = [[Schedule alloc]initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex] ;
                
                [schedulesAssociatedWithThisHomeGame addObject:schedule];
            }
            
        }
    }];
    
    return schedulesAssociatedWithThisHomeGame;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
     //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    
    NSUInteger homeGameIndex = self.selectedIndexPathRow;
    HomeGame *homeGame = self.homeGames[homeGameIndex];

    if([[segue destinationViewController] isKindOfClass:[JoinScheduleTableViewController class]]){
        JoinScheduleTableViewController *jstvc = [segue destinationViewController];
        
        
            jstvc.navigationItem.title = homeGame.opponentName;
            
            /*
            NSArray *schedulesAssociatedWithThisHomeGame = [self getSchedulesAssociatedWithHomeGameIndex:homeGameIndex];
            jstvc.schedulesAssociatedWithThisHomeGame = schedulesAssociatedWithThisHomeGame;*/
        
        jstvc.homeGameIndex = homeGameIndex;
        
    }

    //this doesn't work because it's a modal segue and the destination view controller is a navigation controller and not addschedules
    /*if([[segue destinationViewController] isKindOfClass:[AddSchedulesTableViewController class]]){
        AddSchedulesTableViewController *astvc = [segue destinationViewController];
        
            astvc.homeGameIndex = homeGameIndex;
        
    }*/
    if([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *nc = [segue destinationViewController];
        AddSchedulesTableViewController *astvc = nc.childViewControllers[0];
        astvc.homeGameIndex = homeGameIndex;
    }
    
}


@end
