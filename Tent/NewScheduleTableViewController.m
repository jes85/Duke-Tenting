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

    //[self getHomeGamesDataFromUserDefaults];
    
    
    [self loadHomeGameScheduleData];
    [self calculateScrollRow];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Home Game Data"];
    [refresh addTarget:self action:@selector(refreshHomeGames) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    /*
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay) fromDate:[NSDate date]];
    if(components.day == 16){ //change to only do it once a month or something and make sure it does it that month (maybe push notification is better)
        [self checkForUpdatedHomeGameData];
    }
     */
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(NSUInteger)calculateScrollRow
{
    NSUInteger scrollRow = 0;
    HomeGame *lastGame = self.homeGames[self.homeGames.count-1];
    if([lastGame.gameTime timeIntervalSinceNow] < 0) return 0; //if all games have occurred, just show all of them
    for(int i=0;i<self.homeGames.count - 1;i++){ //don't need to check the last game twice
        HomeGame *game = self.homeGames[i];
        if([game.gameTime timeIntervalSinceNow] < 0){
            scrollRow = i+1;
            
        }
    }
    return scrollRow;
}

-(void)refreshHomeGames
{
    [self checkForUpdatedHomeGameData];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
    
}
-(void)stopRefresh
{
    [self.refreshControl endRefreshing];
}
//TODO: Review the process of retreiving home games.
//don't do user defaults. only check parse on push notification and update local file instead of user defaults
-(void)getHomeGamesDataFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:kUserDefaultsHomeGamesData]; //testing
    NSData *currentData = [userDefaults objectForKey:kUserDefaultsHomeGamesData];
    if(!currentData){
        [NewScheduleTableViewController loadHomeGameScheduleDataFromParseWithBlock:^(NSArray *updatedHomeGamesArray, NSError *error) {
            NSData *updatedData = [NSKeyedArchiver archivedDataWithRootObject:updatedHomeGamesArray];
            [userDefaults setObject:updatedData forKey:kUserDefaultsHomeGamesData];
            self.homeGames = updatedHomeGamesArray;
            [self calculateScrollRow];
        }];
    }else{
        NSArray *currentHomeGameDataArray = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:currentData];
        self.homeGames = currentHomeGameDataArray;
        [self calculateScrollRow];
        
    }
}
#pragma mark - Update Home Games Data from Parse
// TODO: Review the process of retreiving home games.
-(void)checkForUpdatedHomeGameData
{
    [NewScheduleTableViewController loadHomeGameScheduleDataFromParseWithBlock:^(NSArray *updatedHomeGamesArray, NSError *error) {
        if(!error){
            //update file
            /*
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
            }*/
            //update self.homeGames
            //check first to see if they are different
            //should store myScheduleHomeGameParseIds instead of myScheduleHomeGameIndices
            self.homeGames = updatedHomeGamesArray;
            [self.tableView reloadData];
            

        }
    }];
}

+(void)loadHomeGameScheduleDataFromParseWithBlock:(void (^) (NSArray *updatedHomeGamesArray, NSError *error))completionHander
{
    PFQuery *query = [PFQuery queryWithClassName:kHomeGameClassName];
    [query orderByAscending:kHomeGamePropertyGameTime];
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
                
                /*
                [components setYear:[parseHomeGame[@"date_year"] integerValue]];
                [components setMonth: [parseHomeGame[@"date_month"] integerValue]];
                [components setDay:[parseHomeGame[@"date_day"] integerValue]];
                [components setHour:[parseHomeGame[@"time_hour"]integerValue]];
                [components setMinute:[parseHomeGame[@"time_minutes"]integerValue]];
                [components setWeekday:[parseHomeGame[@"date_weekday"]integerValue]];
                NSDate *gameTime = [calendar dateFromComponents:components];
                 */
                //TODO: uncomment this line and comment lines above once change scraper to put dates in date format on parse
                NSDate *gameTime = parseHomeGame[kHomeGamePropertyGameTime];
                NSString *opponent = parseHomeGame[kHomeGamePropertyOpponent];
                BOOL isExhibition = [parseHomeGame[kHomeGamePropertyExhibition] boolValue];
                BOOL isConferenceGame = [parseHomeGame[kHomeGamePropertyConferenceGame] boolValue];
                NSUInteger index = [parseHomeGame[kHomeGamePropertyIndex] unsignedIntegerValue];
                
                HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition isConferenceGame:isConferenceGame index:index parseObjectID:parseHomeGame.objectId];
                [homeGamesTemp addObject: homeGame];
            }
            
            /*
            NSSortDescriptor *sortByStartDate = [NSSortDescriptor sortDescriptorWithKey:@"gameTime" ascending:YES];
            NSArray *homeGamesData = (NSArray *)[homeGamesTemp sortedArrayUsingDescriptors:@[sortByStartDate]];
             */
            
            NSArray *homeGamesArray = (NSArray *)homeGamesTemp;
            completionHander(homeGamesArray, error);
            
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
        
        HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition isConferenceGame:isConferenceGame index:i parseObjectID:nil];
        [homeGamesTemp addObject: homeGame];
    }
    
    self.homeGames = [homeGamesTemp copy]; // is copy necessary?
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
    if(homeGame.isExhibition) opponentNameLabelText = [opponentNameLabelText stringByAppendingString:@" (Ex.)"];
    if(homeGame.isConferenceGame) opponentNameLabelText = [opponentNameLabelText stringByAppendingString:@" *"];
    
    
    // Gametime
    NSString *dateLabelText = [Constants formatDate:homeGame.gameTime withStyle:NSDateFormatterShortStyle];
    NSString *timeLabelText = [Constants formatTime:homeGame.gameTime withStyle:NSDateFormatterShortStyle];
    
    if(![self.mySchedulesHomeGameIndexes containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        // User has not joined a group schedule for this home game
        
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
        // User already joined a group schedule for this home game.
        JoinedHomeGameTableViewCell *cell = (JoinedHomeGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"JoinedHomeGameTVC" forIndexPath:indexPath];
        
        // Set text of labels
        cell.opponentNameLabel.text = opponentNameLabelText;
        cell.gametimeLabel.text = [[dateLabelText stringByAppendingString:@" "] stringByAppendingString:timeLabelText];
        
        // Disable Cell If Game Has Occurred
        [self disableCell:cell IfGameAlreadyOccured:homeGame.gameTime];
        
        return cell;

    }

}

-(void)disableCell:(UITableViewCell *)cell IfGameAlreadyOccured:(NSDate *)gametime
{
    if([gametime timeIntervalSinceNow] < 0){ //could save this calculation when calculate scroll row to save some time
        //cell.userInteractionEnabled = NO
        //cell.joinButton.userInteractionEnabled = NO;
        //cell.createButton.userInteractionEnabled = NO;
        if([cell isKindOfClass:[HomeGamesTableViewCell class]]) [self changeJoinCreateButtonsOnCell:(HomeGamesTableViewCell *)cell toUserInteractionEnabled:NO];
        cell.backgroundColor = [UIColor grayColor];
    }else{
        //cell.userInteractionEnabled = YES;
        //cell.joinButton.userInteractionEnabled = YES;
        //cell.createButton.userInteractionEnabled = YES;
        if([cell isKindOfClass:[HomeGamesTableViewCell class]]) [self changeJoinCreateButtonsOnCell:(HomeGamesTableViewCell *)cell toUserInteractionEnabled:YES];
        cell.backgroundColor = [UIColor whiteColor];
        
    }

    
}
-(void)changeJoinCreateButtonsOnCell:(HomeGamesTableViewCell *)cell toUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    cell.joinButton.userInteractionEnabled = userInteractionEnabled;
    cell.createButton.userInteractionEnabled = userInteractionEnabled;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert;
    HomeGame *hg = self.homeGames[indexPath.row];
    if([hg.gameTime timeIntervalSinceNow] < 0){
        alert = [UIAlertController alertControllerWithTitle:@"Game Over" message:@"You cannot create or join a schedule for this game because the game already occurred." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

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
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    HomeGame *homeGame = self.homeGames[self.selectedIndexPathRow];

    if([[segue destinationViewController] isKindOfClass:[JoinScheduleTableViewController class]]){
        JoinScheduleTableViewController *jstvc = [segue destinationViewController];
        
        jstvc.navigationItem.title = homeGame.opponentName;
        jstvc.homeGame = homeGame;
        
    }

    if([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *nc = [segue destinationViewController];
        if([nc.childViewControllers[0] isKindOfClass:[CreateScheduleTableViewController class]]){
            CreateScheduleTableViewController *cstvc = nc.childViewControllers[0];
            cstvc.homeGame = homeGame;
            cstvc.gameTime = homeGame.gameTime;
        }
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


@end
