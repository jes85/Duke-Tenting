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
#import "JoinedHomeGameTableViewCell.h"
#import "JoinScheduleTableViewController.h"
#import "CreateScheduleTableViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

#import "MySchedulesTableViewController.h"
//static const NSUInteger numHomeGames = 18;

@interface NewScheduleTableViewController ()
@property (nonatomic) NSUInteger selectedIndexPathRow;
@end

@implementation NewScheduleTableViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.test = @"no";
    //[self loadHomeGameScheduleData];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay) fromDate:[NSDate date]];
    if(components.day == 16){ //change to only do it once a month or something and make sure it does it that month (maybe push notification is better)
        [self checkForUpdatedHomeGameData];
    }
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)checkForUpdatedHomeGameData
{
    [NewScheduleTableViewController loadHomeGameScheduleDataFromParseWithBlock:^(NSArray *updatedHomeGamesArray, NSError *error) {
        if(!error){
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSData *currentData = [userDefaults objectForKey:kUserDefaultsHomeGamesData];
            NSArray *currentHomeGameDataArray = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:currentData];
            
            if(![currentHomeGameDataArray isEqual:updatedHomeGamesArray]){
                NSData *updatedData = [NSKeyedArchiver archivedDataWithRootObject:updatedHomeGamesArray];
                [userDefaults setObject:updatedData forKey:kUserDefaultsHomeGamesData];
                self.homeGames = updatedHomeGamesArray;
                MySchedulesTableViewController *mstvc = (MySchedulesTableViewController *)self.parentViewController.childViewControllers[0]; // change to delegate
                //recalculate scroll position
                //maybe give loading wheel notice that it's loading something
                //maybe don't automatically reload. but have button for them to load 2015-16 data
                mstvc.homeGames = self.homeGames;
                [self.tableView reloadData];
            }
            

        }
    }];
}

+(void)loadHomeGameScheduleDataFromParseWithBlock:(void (^) (NSArray *updatedHomeGamesArray, NSError *error))completionHander
{
    PFQuery *query = [PFQuery queryWithClassName:@"HomeGame"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseHomeGames, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu home games.", (unsigned long)parseHomeGames.count);
            // Do something with the found objects
            NSMutableArray *homeGamesTemp = [[NSMutableArray alloc]initWithCapacity:parseHomeGames.count];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc]init];
            for (PFObject *parseHomeGame in parseHomeGames) {
                NSLog(@"%@", parseHomeGame.objectId);
                [components setYear:[parseHomeGame[@"date_year"] integerValue]];
                [components setMonth: [parseHomeGame[@"date_month"] integerValue]];
                [components setDay:[parseHomeGame[@"date_day"] integerValue]];
                [components setHour:[parseHomeGame[@"time_hour"]integerValue]];
                [components setMinute:[parseHomeGame[@"time_minutes"]integerValue]];
                [components setWeekday:[parseHomeGame[@"date_weekday"]integerValue]];
                NSDate *gameTime = [calendar dateFromComponents:components];
                NSString *opponent = parseHomeGame[@"opponent"];
                BOOL isExhibition = [parseHomeGame[@"exhibition"] boolValue];
                BOOL isConferenceGame = [parseHomeGame[@"conference_game"] boolValue];
                
                HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition isConferenceGame:isConferenceGame];
                [homeGamesTemp addObject: homeGame];
            }
            
            NSSortDescriptor *sortByStartDate = [NSSortDescriptor sortDescriptorWithKey:@"gameTime" ascending:YES];
            NSArray *homeGamesData = (NSArray *)[homeGamesTemp sortedArrayUsingDescriptors:@[sortByStartDate]];
            completionHander(homeGamesData, error);
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completionHander(nil, error);
        }
    }];
}

/*!
 *  Load Duke Basketball's home game schedule into self.homeGames
 */
-(void)loadHomeGameScheduleData
{
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/jeremy/Developer/Xcode/Tent/Tent/dukeschedule.txt" options:0 error:&error];
    NSString *scheduleFileContents = [NSString stringWithContentsOfFile:@"/Users/jeremy/Developer/Xcode/Tent/Tent/dukeschedule.txt" encoding: NSUTF8StringEncoding error:&error];
    NSArray *jsonHomeGames = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSMutableArray *homeGamesTemp = [[NSMutableArray alloc]initWithCapacity:jsonHomeGames.count];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    
    
    for(int i = 0; i<jsonHomeGames.count; i++){
        NSDictionary *gameInfo = jsonHomeGames[i];
        [components setYear:[gameInfo[@"date_year"] integerValue]];
        [components setMonth: [gameInfo[@"date_month"] integerValue]];
        [components setDay:[gameInfo[@"date_day"] integerValue]];
        [components setHour:[gameInfo[@"time_hour"]integerValue]];
        [components setMinute:[gameInfo[@"time_minutes"]integerValue]];
        [components setWeekday:[gameInfo[@"date_weekday"]integerValue]];
        NSDate *gameTime = [calendar dateFromComponents:components];
        NSString *opponent = gameInfo[@"opponent"];
        BOOL isExhibition = [gameInfo[@"exhibition"] boolValue];
        BOOL isConferenceGame = [gameInfo[@"conference_game"] boolValue];
        
        if([gameTime timeIntervalSinceNow] < 0){
            self.scrollRow=i+1;
        }
        
        HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition isConferenceGame:isConferenceGame];
        [homeGamesTemp addObject: homeGame];
        
    }
    self.homeGames = [homeGamesTemp copy];

    
    /*
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
    */
    
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

    HomeGame *homeGame = self.homeGames[indexPath.row];
    
    
    // Opponent name
    NSString *opponentNameLabelText = homeGame.opponentName;
    BOOL isExhibition = homeGame.isExhibition;
    if(isExhibition) opponentNameLabelText = [opponentNameLabelText stringByAppendingString:@" (Ex.)"];//(Exhibition)
    
    
    // Gametime
    NSString *dateLabelText = [Constants formatDate:homeGame.gameTime withStyle:NSDateFormatterShortStyle];
    
    NSString *timeLabelText = [Constants formatTime:homeGame.gameTime withStyle:NSDateFormatterShortStyle];
    
    JoinedHomeGameTableViewCell *cell;
    
    if(![self.mySchedulesHomeGameIndexes containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        HomeGamesTableViewCell *cell = (HomeGamesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HomeGameTVC" forIndexPath:indexPath];
        
        // Set text of labels
        cell.opponentNameLabel.text = opponentNameLabelText;
        cell.gametimeLabel.text = [[dateLabelText stringByAppendingString:@" "] stringByAppendingString:timeLabelText];
        
        // Disable Cell If Game Has Occurred
        [self disableCell:cell IfGameAlreadyOccured:homeGame.gameTime];
        
        // Configure join button
        cell.delegate = self;

        return cell;
    }else{
        JoinedHomeGameTableViewCell *cell = (JoinedHomeGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"JoinedHomeGameTVC" forIndexPath:indexPath];
        
        // Set text of labels
        cell.opponentNameLabel.text = opponentNameLabelText;
        cell.gametimeLabel.text = [[dateLabelText stringByAppendingString:@" "] stringByAppendingString:timeLabelText];
        
        // Disable Cell If Game Has Occurred
        [self disableCell:cell IfGameAlreadyOccured:homeGame.gameTime];
        
        return cell;

    }

    
   // Present the most recent future game at the top of the page
    
    

}

-(void)disableCell:(UITableViewCell *)cell IfGameAlreadyOccured:(NSDate *)gametime
{
    if([gametime timeIntervalSinceNow] < 0){ //could save this calculation when calculate scroll row to save sometime
        cell.userInteractionEnabled = NO;
        //cell.joinButton.userInteractionEnabled = NO;
        //cell.createButton.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor grayColor];
    }else{
        cell.userInteractionEnabled = YES;
        //cell.joinButton.userInteractionEnabled = YES;
        //cell.createButton.userInteractionEnabled = YES;
        cell.backgroundColor = [UIColor whiteColor];
        
    }

    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert;
    HomeGame *hg = self.homeGames[indexPath.row];

    if([self.mySchedulesHomeGameIndexes containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        NSString *title = hg.opponentName;
       
        NSString *message = @"You have already created or joined a schedule for this game. Remove yourself from that schedule if you wish to join another schedule for this game.";
        alert = [UIAlertController alertControllerWithTitle:title
                                                    message:message
                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        [alert addAction:okAction];

    }else{
        
        NSString *title = hg.opponentName;
        
        NSString *message = @"Do you want to join an existing group or create a new schedule?";

        alert = [UIAlertController alertControllerWithTitle:title
                                                    message: message
                                             preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        UIAlertAction* joinAction = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.selectedIndexPathRow = indexPath.row;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self joinSchedule];

        }];
        UIAlertAction* createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.selectedIndexPathRow = indexPath.row;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self createSchedule];
            
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:joinAction];
        [alert addAction:createAction];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)joinSchedule
{
    [self performSegueWithIdentifier:@"Join" sender:self]; //change string to constant and sender to button
    
}
-(void)createSchedule
{
    [self performSegueWithIdentifier:@"Create" sender:self]; //change string to constant and sender to button

    
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
    NSLog(@"index: %ld", (long)indexPath.row);
    
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
        CreateScheduleTableViewController *cstvc = nc.childViewControllers[0];
        cstvc.homeGameIndex = homeGameIndex;
        cstvc.gameTime = homeGame.gameTime;
    }
    
    
    //Segue not called when hit back button. Figure out way to keep self.homeGames consistent when updating homeGame data from Parse
    /*
    if([[segue destinationViewController] isKindOfClass:[MySchedulesTableViewController class]]){
        MySchedulesTableViewController *jstvc = [segue destinationViewController];
        self.homeGames = nil;
        NSArray *array = jstvc.homeGames;
    }
     */
    
}


@end
