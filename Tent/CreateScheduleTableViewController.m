//
//  CreateScheduleTableViewController.m
//  Tent
//
//  Created by Jeremy on 8/10/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "CreateScheduleTableViewController.h"
#import "NameOfScheduleTableViewCell.h"
#import "PrivacyTableViewCell.h"
#import "PasswordTableViewCell.h"
#import "MySchedulesTableViewController.h"
#import "Schedule.h"

#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kTitleKey       @"title"            // key for obtaining the data source item's title
#define kDateKey        @"date"             // key for obtaining the data source item's date value
#define kStatusKey      @"status"           // key for obtaining privacy setting

// keep track of which rows have date cells
#define kDateStartRow   1
#define kDateEndRow     2


// Time Interval Length
#define kTimeIntervalLengthInSeconds     3600  // one hour for now (later make this a property that changes based on user setting


static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kNameCellID = @"nameCell";     // the name of schedule cell
static NSString *kPrivacyCellID = @"privacyCell"; // the privacy cell
static NSString *kPasswordCellID = @"passwordCell"; //the password cell


#define kPrivacyValuePrivate                    @"private"
#define kPrivacyValuePublic                     @"public"

#pragma mark -
@interface CreateScheduleTableViewController ()

@property (nonatomic) BOOL datesValid;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger datePickerCellRowHeight;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;


@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSDate *roundedStartDateAtViewDidLoad;
@property (nonatomic) NSDate *roundedEndDateAtViewDidLoad;
@property (nonatomic, weak) UITextField *nameOfScheduleTextField;
@property (nonatomic, weak) UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) BOOL private;
@property (nonatomic) NSString *password;

@property (nonatomic) NSUInteger intervalLengthInMinutes; //use this later

@end

@implementation CreateScheduleTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *currentDateComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit) fromDate:currentDate];
    NSInteger currentDateSecond = [currentDateComponents second];
    NSInteger currentDateMinute = [currentDateComponents minute];
    
    //NSInteger secondsTo15min = (15 - (currentDateMinute%15))*60 - currentDateSecond;
    //NSDate *roundedDate = [NSDate dateWithTimeInterval:secondsTo15min sinceDate:currentDate];

    self.intervalLengthInMinutes = 60; //later this will be set depending on the desired interval length
    NSInteger secondsToRoundedDate = (self.intervalLengthInMinutes - (currentDateMinute%self.intervalLengthInMinutes))*60 - currentDateSecond;
    NSDate *roundedDate = [NSDate dateWithTimeInterval:secondsToRoundedDate sinceDate:currentDate];

    self.roundedStartDateAtViewDidLoad = roundedDate;
    //self.roundedEndDateAtViewDidLoad = [self.gameTime copy];
    
    // maybe incorporate these into the model somehow (if I get rid of mutableCopy do I no longer have to update the model if I update startdate and enddate?)
    self.startDate = roundedDate;
    self.endDate = self.gameTime; //maybe change to 1.5 hours earlier
   
    // setup our data source
    NSMutableDictionary *itemOne = [@{ kTitleKey : @"Tap a cell to change its date:" } mutableCopy]; //delete this later or change it to Name label
    NSMutableDictionary *itemTwo = [@{ kTitleKey : @"Start Date",
                                       kDateKey : self.startDate} mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey : @"End Date",
                                         kDateKey : self.endDate} mutableCopy];
    NSMutableDictionary *itemFour = [@{ kTitleKey : @"Privacy", kStatusKey: @"Private"} mutableCopy];
    NSMutableDictionary *itemFive = [@{ kTitleKey : @"Password"} mutableCopy];
    
     self.dataArray = @[itemOne, itemTwo, itemThree, itemFour, itemFive];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];    // picker date-style formats
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    
    
    
    
    // obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    UITableViewCell *datePickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    self.datePickerCellRowHeight = CGRectGetHeight(datePickerViewCellToCheck.frame);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.nameOfScheduleTextField];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    self.datesValid = YES;
    self.doneButton.enabled = NO;
    self.private = YES;
    
   
  
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.nameOfScheduleTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    
}

-(BOOL)shouldEnableDoneButton
{
    BOOL enableDoneButton = NO;
    if(self.nameOfScheduleTextField.text!=nil &&  self.nameOfScheduleTextField.text.length>0 && self.passwordTextField.text!= nil && self.passwordTextField.text.length > 0 && self.datesValid == YES)
    {

        
        enableDoneButton = YES;
    }
    return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note
{
    self.doneButton.enabled = [self shouldEnableDoneButton];
}

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
            [targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:NO];
            
            // also update maximum/minimum date depending on which one it is (have to do this since we're sharing the same date picker
            if([[itemData valueForKey:kTitleKey ] isEqual:@"Start Date"]){
                [targetedDatePicker setMinimumDate:self.roundedStartDateAtViewDidLoad];
            }
            /* had a maximum end date, but decided to get rid of it
            else if([[itemData valueForKey:kTitleKey ] isEqual:@"End Date"]){
                [targetedDatePicker setMaximumDate:self.roundedEndDateAtViewDidLoad];
            }
            */
        }
    }
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells. (WHY DO I NEED THIS?)
 */
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if ((indexPath.row == kDateStartRow) ||
        (indexPath.row == kDateEndRow || ([self hasInlineDatePicker] && (indexPath.row == kDateEndRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
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
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.dataArray.count;
        return ++numRows;
    }
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? self.datePickerCellRowHeight : self.tableView.rowHeight);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger numCells = [self.dataArray count];
    if([self hasInlineDatePicker]) numCells++;
    
    if (indexPath.row == 0)
     {
         NameOfScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNameCellID forIndexPath:indexPath];
         self.nameOfScheduleTextField = cell.nameOfScheduleTextField;
         [self.nameOfScheduleTextField becomeFirstResponder];
         self.nameOfScheduleTextField.delegate = self;
         //self.nameOfScheduleTextField.borderStyle = UITextBorderStyleNone;
         
         return cell;
     }
    
    
    //EDIT: change password cell to go away if they pick public
    else if(indexPath.row == numCells-2){ // 2nd last row (privacy)
        PrivacyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPrivacyCellID forIndexPath:indexPath];
        NSDictionary *itemData = self.dataArray[numCells-2];

        cell.statusLabel.text = [itemData valueForKey:kStatusKey];
        return cell;
        
    }
    else if (indexPath.row == numCells-1){ //last row (password)
        //password cell is same form as name of schedule cell (change name to be more general)
        PasswordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPasswordCellID forIndexPath:indexPath];
        cell.passwordLabel.text = @"Password: ";
        self.passwordTextField = cell.passwordTextField;
        self.passwordTextField.delegate = self;
        return cell;
    }
    UITableViewCell *cell = nil;
    
    NSString *cellID = kDateCellID;
    
    if ([self indexPathHasPicker:indexPath])
    {
        // the indexPath is the one containing the inline date picker
        cellID = kDatePickerID;     // the current/opened date picker cell
    }
    else if ([self indexPathHasDate:indexPath])
    {
        // the indexPath is one that contains the date information
        cellID = kDateCellID;       // the start/end date cells
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    
    
    // if we have a date picker open whose cell is above the cell we want to update,
    // then we have one more cell than the model allows
    //
    NSInteger modelRow = indexPath.row;
    if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row <= indexPath.row)
    {
        modelRow--;
    }
    
    NSDictionary *itemData = self.dataArray[modelRow];
    
    // proceed to configure our cell
    if ([cellID isEqualToString:kDateCellID])
    {
        // we have either start or end date cells, populate their date field
        //
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    

    // Configure the cell...
    
    return cell;
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    [self hideInLineDatePickerIfShown];
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([self.nameOfScheduleTextField isFirstResponder] && cell.reuseIdentifier != kNameCellID){
        [self.nameOfScheduleTextField resignFirstResponder];
    }
    else if([self.passwordTextField isFirstResponder] && cell.reuseIdentifier != kPasswordCellID){
        [self.passwordTextField resignFirstResponder];
    }
    if (cell.reuseIdentifier == kDateCellID)
    {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
    else
    {
        [self hideInLineDatePickerIfShown];
    }
}

-(void)hideInLineDatePickerIfShown
{
    if([self hasInlineDatePicker]){
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
        [self.tableView endUpdates];
    }
    
}
#pragma mark - Actions
/*! User chose to change the date by changing the values inside the UIDatePicker.
 
 @param sender The sender for this action: UIDatePicker.
 */

- (IBAction)dateAction:(id)sender {
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
    NSLog(@"Minimum date %@", targetedDatePicker.minimumDate);
    // If targeted date is less than minimum date, return (first check if it has a minimum date
    if(targetedDatePicker.minimumDate && [targetedDatePicker.date compare:targetedDatePicker.minimumDate] < 0) return;
    
    // update our data model (unncessary since I'm using self.startDate and self.endDate as model?)
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kDateKey];
    
    // update model's start or end data
    if(targetedCellIndexPath.row ==kDateStartRow) self.startDate = targetedDatePicker.date;
    else if(targetedCellIndexPath.row == kDateEndRow) self.endDate = targetedDatePicker.date;

    // update the cell's date string
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
    
    // make sure the dates are valid. if not, display red strikethrough and disable done button
    if(![self checkIfValidDates]){
        [self displayInvalidDateForCell:cell];
    }else{
        [self displayValidDateForCell:cell];
        
        NSIndexPath *otherDateCellIndexPath = [NSIndexPath indexPathForRow:(targetedCellIndexPath.row == kDateStartRow) ? targetedCellIndexPath.row + 2 : targetedCellIndexPath.row - 1 inSection:0];
        UITableViewCell *otherDateCell = [self.tableView cellForRowAtIndexPath:otherDateCellIndexPath];
        [self displayValidDateForCell:otherDateCell];

        
    }
    self.doneButton.enabled = [self shouldEnableDoneButton];
   }

-(BOOL)checkIfValidDates
{
    return [self.endDate compare:[NSDate dateWithTimeInterval:kTimeIntervalLengthInSeconds sinceDate:self.startDate]] >= 0;
}
-(void)displayInvalidDateForCell:(UITableViewCell *)cell
{
    cell.detailTextLabel.textColor = [UIColor redColor];
    NSDictionary* attributes = @{ NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle] };
    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:cell.detailTextLabel.text attributes:attributes];
    cell.detailTextLabel.attributedText = attrText;
    self.datesValid = NO;
}
-(void)displayValidDateForCell:(UITableViewCell *)cell
{
    if(cell.detailTextLabel.textColor != [UIColor blackColor]){//if it's already valid, no need to change it
        cell.detailTextLabel.textColor = [UIColor blackColor];
        NSDictionary* attributes = @{ NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone] };
        NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:cell.detailTextLabel.text attributes:attributes];
        cell.detailTextLabel.attributedText = attrText;
        self.datesValid = YES;
    }
    
}
- (IBAction)textFieldDoneEditing:(id)sender {
    if([self.nameOfScheduleTextField isFirstResponder]){
        [self.nameOfScheduleTextField resignFirstResponder];
    }else if([self.passwordTextField isFirstResponder]){
        [self.passwordTextField resignFirstResponder];
    }
}


- (IBAction)touchOutsideOfTableView:(id)sender {
    if([self.nameOfScheduleTextField isFirstResponder]){
        [self.nameOfScheduleTextField resignFirstResponder];
    }else if([self.passwordTextField isFirstResponder]){
        [self.passwordTextField resignFirstResponder];
    }
}

- (IBAction)privacyChanged:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    NSUInteger row = [self hasInlineDatePicker] ? self.dataArray.count-1: self.dataArray.count-2;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    PrivacyTableViewCell *cell = (PrivacyTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *itemData = self.dataArray[4];
    

    if(s.on == YES){
        self.private = YES;
        [itemData setValue:@"Private" forKey:kStatusKey];//unnecessary
        cell.statusLabel.text = @"Private";
        
    }
    else{
        self.private = NO;
        [itemData setValue:@"Public" forKey:kStatusKey];//unnecessary
        cell.statusLabel.text = @"Public";
    }
    

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self hideInLineDatePickerIfShown];
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if(sender == self.doneButton){
        /*Schedule *scheduleToAdd = [[Schedule alloc]initWithName:self.nameOfScheduleTextField.text startDate:self.startDate endDate:self.endDate];
        scheduleToAdd.privacy = self.private ? kPrivacyValuePrivate: kPrivacyValuePublic; ;
        if(self.private) scheduleToAdd.password = self.passwordTextField.text; //add this to init
        scheduleToAdd.homeGameIndex = self.homeGameIndex;
        */
        
        Schedule *scheduleToAdd = [[Schedule alloc]initWithName:self.nameOfScheduleTextField.text availabilitiesSchedule:[[NSMutableArray alloc] init] assignmentsSchedule:nil numHourIntervals:0 startDate:self.startDate endDate:self.endDate privacy:self.private ? kPrivacyValuePrivate : kPrivacyValuePublic password:self.passwordTextField.text homeGameIndex:self.homeGameIndex];
        
       
        MySchedulesTableViewController *mstvc = [segue destinationViewController];
        mstvc.scheduleToAdd = scheduleToAdd;
    }
    

}


@end
