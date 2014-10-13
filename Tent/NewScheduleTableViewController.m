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
#import "CreateScheduleTableViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"


static const NSUInteger numHomeGames = 18;

@interface NewScheduleTableViewController ()
@property (nonatomic) NSArray *homeGames;

@property (nonatomic) NSUInteger selectedIndexPathRow;
@end

@implementation NewScheduleTableViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadHomeGameScheduleData];
    
    
}

/*!
 *  Load Duke Basketball's home game schedule into self.homeGames
 */
-(void)loadHomeGameScheduleData
{
    
    NSMutableArray *homeGamesTemp = [[NSMutableArray alloc]initWithCapacity:numHomeGames];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setYear:2014];
    
    
    //Countdown To Craziness Saturday Oct. 25 8 pm
    [components setMonth: 10];
    [components setDay:25];
    [components setHour:20];
    [components setWeekday:7];
    NSDate *gameTime = [calendar dateFromComponents:components];
    
    NSString *opponent = @"Countdown To Craziness";
    BOOL isExhibition = NO;
    
    HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame ];
    
    //Livingstone (Exhibition) Tuesday Nov. 4, 7 pm
    [components setMonth: 11];
    [components setDay:4];
    [components setHour:19];
    [components setWeekday:3];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Livingstone";
    isExhibition = YES;
    
    HomeGame *homeGame1 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame1 ];
    
    
    //Central Missouri (Exhibition) Saturday Nov. 8, 1 pm
    [components setMonth: 11];
    [components setDay:8];
    [components setHour:13];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"C. Missouri";
    isExhibition = YES;
    
    HomeGame *homeGame2 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame2 ];
    
    //Presbyterian Friday Nov. 14, 6 pm
    [components setMonth: 11];
    [components setDay:14];
    [components setHour:18];
    [components setWeekday:6];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Presbyterian";
    isExhibition = NO;
    
    HomeGame *homeGame3 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame3 ];
    
    //Fairfield Saturday Nov.15, 8 pm
    [components setMonth: 11];
    [components setDay:15];
    [components setHour:20];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Fairfield";
    isExhibition = NO;
    
    HomeGame *homeGame4 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame4 ];
    
    //Furman Wednesday Nov. 26, 5 pm
    [components setMonth: 11];
    [components setDay:26];
    [components setHour:17];
    [components setWeekday:4];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Furman";
    isExhibition = NO;
    
    HomeGame *homeGame5 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame5 ];
    
    //Army Sunday Nov. 30, 12pm
    [components setMonth: 11];
    [components setDay:30];
    [components setHour:12];
    [components setWeekday:1];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Army";
    isExhibition = NO;
    
    HomeGame *homeGame6 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame6 ];
    
    //Elon Monday Dec. 15, 7 pm
    [components setMonth: 12];
    [components setDay:15];
    [components setHour:19];
    [components setWeekday:2];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Elon";
    isExhibition = NO;
    
    HomeGame *homeGame7 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame7 ];
    
    //Toledo Monday Dec. 29, 7 pm
    [components setMonth: 12];
    [components setDay:29];
    [components setHour:19];
    [components setWeekday:2];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Toledo";
    isExhibition = NO;
    
    HomeGame *homeGame8 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame8 ];
    
    //Wofford Wednesday Dec. 31, 3 pm
    [components setMonth: 12];
    [components setDay:31];
    [components setHour:15];
    [components setWeekday:4];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Wofford";
    isExhibition = NO;
    
    HomeGame *homeGame9 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame9 ];
    
    //Boston College Saturday Jan. 3, 4 pm
    [components setMonth: 1];
    [components setDay:3];
    [components setHour:16];
    [components setWeekday:7];
    [components setYear:2015];

    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Boston College";
    isExhibition = NO;
    
    HomeGame *homeGame10 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame10 ];
    
    //Miami Tuesday Jan. 13, 9 pm
    [components setMonth: 1];
    [components setDay:13];
    [components setHour:21];
    [components setWeekday:3];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Miami";
    isExhibition = NO;
    
    HomeGame *homeGame11 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame11 ];
    
    //Pittsburgh Monday Jan. 19, 7 pm
    [components setMonth: 1];
    [components setDay:19];
    [components setHour:19];
    [components setWeekday:2];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Pittsburgh";
    isExhibition = NO;
    
    HomeGame *homeGame12 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame12 ];
    
    //Georgia Tech Wednesday Feb 04, 7pm
    [components setMonth: 2];
    [components setDay:4];
    [components setHour:19];
    [components setWeekday:4];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Georgia Tech";
    isExhibition = NO;
    
    HomeGame *homeGame13 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame13 ];
    
    //Notre Dame Saturday Feb 07, 1 pm
    [components setMonth: 2];
    [components setDay:7];
    [components setHour:13];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Notre Dame";
    isExhibition = NO;
    
    HomeGame *homeGame14 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame14 ];
    
    // UNC Wednesday Feb. 18, 9 pm
    [components setMonth: 2];
    [components setDay:18];
    [components setHour:21];
    [components setWeekday:4];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"UNC";
    isExhibition = NO;
    
    HomeGame *homeGame15 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame15 ];
    
    //Clemson Saturday Feb 21, 4 pm
    [components setMonth: 2];
    [components setDay:21];
    [components setHour:16];
    [components setWeekday:7];
    
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Clemson";
    isExhibition = NO;
    
    HomeGame *homeGame16 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame16 ];
    
    //Syracuse Saturday Feb. 28, Time TBA
    [components setMonth: 2];
    [components setDay:28];
    [components setHour:19];
    [components setWeekday:7];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Syracuse";
    isExhibition = NO;
    
    HomeGame *homeGame17 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame17 ];
    
    //Wake Forest Wednesday March 04, 8pm
    [components setMonth: 3];
    [components setDay:4];
    [components setHour:20];
    [components setWeekday:4];
    gameTime = [calendar dateFromComponents:components];
    
    opponent = @"Wake Forest";
    isExhibition = NO;
    
    HomeGame *homeGame18 = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition];
    [homeGamesTemp addObject: homeGame18 ];
    
    
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
    if(isExhibition) opponentNameLabelText = [opponentNameLabelText stringByAppendingString:@" (Ex.)"];//(Exhibition)
   

    // Weekday and calendar date
    NSDate *date = homeGame.gameTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSUInteger weekdayNum = [comps weekday];
    NSString *weekday = [[dateFormatter shortWeekdaySymbols][weekdayNum-1] stringByAppendingString:@". "];
    NSString *dateLabelText = [weekday stringByAppendingString:[dateFormatter stringFromDate:date]];
    
    // Time
    NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc]init];
    [timeDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *timeLabelText = [timeDateFormatter stringFromDate:date];
    
    
    // Set text of labels
    cell.opponentNameLabel.text = opponentNameLabelText;
    cell.dateLabel.text = dateLabelText;
    cell.timeLabel.text = timeLabelText;
    
    
    
    
    //configure join button
    cell.delegate = self;
    
    return cell;
}

/*!
 * Either the create or join schedule button was pressed. 
 * Save the indexPath.row of the cell that was pressed in self.selectedIndexPathRow.
 * Will determine if user pressed "Create" or "Join" in prepareForSegue
 */
-(void)buttonPressed:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.selectedIndexPathRow = indexPath.row;
    
}


-(IBAction)cancelCreateSchedule:(UIStoryboardSegue *)segue
{
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSUInteger homeGameIndex = self.selectedIndexPathRow;
    HomeGame *homeGame = self.homeGames[self.selectedIndexPathRow];

    if([[segue destinationViewController] isKindOfClass:[JoinScheduleTableViewController class]]){
        JoinScheduleTableViewController *jstvc = [segue destinationViewController];
        
        
            jstvc.navigationItem.title = homeGame.opponentName;
            jstvc.homeGameIndex = homeGameIndex;
        
    }

    if([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *nc = [segue destinationViewController];
        CreateScheduleTableViewController *astvc = nc.childViewControllers[0];
        astvc.homeGameIndex = homeGameIndex;
    }
    
}


@end
