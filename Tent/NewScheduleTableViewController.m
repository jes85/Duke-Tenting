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
    
    [self loadHomeGameScheduleDataFromLocalFile];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Home Game Data"];
    [refresh addTarget:self action:@selector(refreshHomeGames) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
       
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self scrollToCurrentInterval];
    
}

-(void)scrollToCurrentInterval
{
    CGPoint point = self.tableView.contentOffset;
    point.y = [self calculateContentOffset];
    self.tableView.contentOffset = point;
}
-(NSUInteger)scrollRow
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
-(NSUInteger)calculateContentOffset
{
    CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollRow inSection:0]];
    return rect.origin.y;
}
-(void)refreshHomeGames
{
    [self checkParseForUpdatedHomeGamesData];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
    
}
-(void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

#pragma mark - Update Home Games Data from Parse
// TODO: Review the process of retreiving home games.
-(void)checkParseForUpdatedHomeGamesData
{
    [NewScheduleTableViewController loadHomeGameScheduleDataFromParseWithBlock:^(NSArray *parseHomeGames, NSArray *updatedHomeGamesArray, NSError *error) {
        if(!error){
            if(![self.homeGames isEqual:updatedHomeGamesArray]){ //maybe only check parseIds and updatedAt
                //update file
                NSDictionary *jsonObject = [self jsonHomeGamesDictionaryFromArrayOfParseHomeGames:parseHomeGames];
                NSError *errorConvertingJSONToData;
                NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&errorConvertingJSONToData];
                NSError *errorWritingDataToFile;
                [data writeToFile:kHomeGamesJSONLocalFilePath options:0 error:&errorWritingDataToFile];
                
                //update self.homeGames
                self.homeGames = updatedHomeGamesArray;
                [self.tableView reloadData];
                //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                //[self scrollToCurrentInterval]; //why doesn't this work?

            }
            

        }
    }];
}
+(void)loadHomeGameScheduleDataFromParseWithBlock:(void (^) (NSArray *parseHomeGames, NSArray *updatedHomeGamesArray, NSError *error))completionHandler
{
    PFQuery *query = [PFQuery queryWithClassName:kHomeGameClassName];
    [query orderByAscending:kHomeGamePropertyGameTime];
    [query whereKey:kHomeGamePropertyCurrentSeason equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseHomeGames, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu home games.", (unsigned long)parseHomeGames.count);
            
            // Create array of Home Games
            NSMutableArray *homeGamesTemp = [[NSMutableArray alloc]initWithCapacity:parseHomeGames.count];
            for (PFObject *parseHomeGame in parseHomeGames) {
                NSLog(@"%@", parseHomeGame.objectId);
                
                NSDate *gameTime = parseHomeGame[kHomeGamePropertyGameTime];
                NSString *opponent = parseHomeGame[kHomeGamePropertyOpponent];
                BOOL isExhibition = [parseHomeGame[kHomeGamePropertyExhibition] boolValue];
                BOOL isConferenceGame = [parseHomeGame[kHomeGamePropertyConferenceGame] boolValue];
                BOOL currentSeason = [parseHomeGame[kHomeGamePropertyCurrentSeason] boolValue];
                HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition isConferenceGame:isConferenceGame currentSeason:currentSeason parseObjectID:parseHomeGame.objectId];
                [homeGamesTemp addObject: homeGame];
            }
            
            NSArray *homeGamesArray = (NSArray *)homeGamesTemp;
            completionHandler(parseHomeGames,homeGamesArray, error);
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completionHandler(nil, nil, error);
        }
    }];
}

/*!
 *  Load Duke Basketball's home game schedule into self.homeGames
 */

-(void)loadHomeGameScheduleDataFromLocalFile
{
    /*
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:NULL];
    for (NSString *fileName in files) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        // do something with `url`
    }
     */
    /*
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HomeGames" ofType:@"json"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSString *docsDir = [NSSearchForDirectoriesInDomains(NSDocumentsDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [docsDir stringByAppendingPathComponent:@"Files.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[url absoluteString] forKey:@"SomeFile.jpeg"];
    [dict writeToFile:plistPath atomically:YES];
    */
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:kHomeGamesJSONLocalFilePath options:0 error:&error];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    self.homeGames = [self homeGamesArrayFromJSONHomeGamesDictionary:jsonObject];
    
}
-(NSDictionary *)jsonHomeGamesDictionaryFromArrayOfParseHomeGames:(NSArray *)parseHomeGames
{
    NSMutableArray *results = [[NSMutableArray alloc]initWithCapacity:parseHomeGames.count];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];

    for(PFObject *parseHomeGame in parseHomeGames){
        [results addObject:@{
                            kHomeGamePropertyConferenceGame: parseHomeGame[kHomeGamePropertyConferenceGame],
                            kParsePropertyCreatedAt: [dateFormatter stringFromDate:parseHomeGame.createdAt],
                            kHomeGamePropertyCurrentSeason: parseHomeGame[kHomeGamePropertyCurrentSeason],
                            kHomeGamePropertyExhibition: parseHomeGame[kHomeGamePropertyExhibition],
                            kHomeGamePropertyGameTime: @{
                                @"__type": @"Date",
                                @"iso": [dateFormatter stringFromDate:parseHomeGame[kHomeGamePropertyGameTime]]
                            },
                            kParsePropertyObjectId: parseHomeGame.objectId,
                            kHomeGamePropertyOpponent: parseHomeGame[kHomeGamePropertyOpponent],
                            kParsePropertyUpdatedAt: [dateFormatter stringFromDate:parseHomeGame.updatedAt]
                            }];
    }
    return @{@"results":results};
}
-(NSArray *)homeGamesArrayFromJSONHomeGamesDictionary:(NSDictionary *)jsonObject
{
    NSArray *jsonHomeGames = jsonObject[@"results"];
    
    NSMutableArray *homeGamesTemp = [[NSMutableArray alloc]initWithCapacity:jsonHomeGames.count];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    for(int i = 0; i<jsonHomeGames.count; i++){
        
        NSDictionary *gameInfo = jsonHomeGames[i];
        NSDictionary *gameTimeObject =gameInfo[kHomeGamePropertyGameTime];
        NSString *gameTimeString = gameTimeObject[@"iso"];
        NSDate *gameTime = [dateFormatter dateFromString:gameTimeString];
        
        NSString *opponent = gameInfo[kHomeGamePropertyOpponent];
        BOOL isExhibition = [gameInfo[kHomeGamePropertyExhibition] boolValue];
        BOOL isConferenceGame = [gameInfo[kHomeGamePropertyConferenceGame] boolValue];
        BOOL currentSeason = [gameInfo[kHomeGamePropertyCurrentSeason] boolValue];
        NSString *parseObjectId = gameInfo[kHomeGamePropertyParseObjectId];
        
        /* doesn't work here because they aren't in sorted order
         if([gameTime timeIntervalSinceNow] < 0){
         self.scrollRow=i+1;
         }
         */
        
        HomeGame *homeGame = [[HomeGame alloc]initWithOpponentName:opponent gameTime:gameTime isExhibition:isExhibition isConferenceGame:isConferenceGame currentSeason:currentSeason parseObjectID:parseObjectId];
        [homeGamesTemp addObject: homeGame];
    }
    
    // only have to sort because Parse exports data by object Id instead of gameTime. maybe there's an option I can't find to export by game time
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:kHomeGamePropertyGameTime ascending:YES];
    return [homeGamesTemp sortedArrayUsingDescriptors:@[sd]];
    //return homeGamesTemp;


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
    //if(homeGame.isConferenceGame) opponentNameLabelText = [opponentNameLabelText stringByAppendingString:@" *"];
    
    
    // Gametime
    NSString *dateLabelText = [Constants formatDate:homeGame.gameTime withStyle:NSDateFormatterShortStyle];
    NSString *timeLabelText = [Constants formatTime:homeGame.gameTime withStyle:NSDateFormatterShortStyle];
    
    if(![self.mySchedulesHomeGameParseIds containsObject:homeGame.parseObjectID]){
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
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    if([self.mySchedulesHomeGameParseIds containsObject:hg.parseObjectID]){
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
