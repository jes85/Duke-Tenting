//
//  CreateScheduleViewController.m
//  Tent
//
//  Created by Jeremy on 10/12/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "CreateScheduleViewController.h"

#import "NameOfScheduleTableViewCell.h"
#import "PrivacyTableViewCell.h"
#import "PasswordTableViewCell.h"
#import "MySchedulesTableViewController.h"
#import "Schedule.h"
#import "IntervalsDisplayData.h"

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

#pragma mark -

@interface CreateScheduleViewController ()

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
@property (nonatomic, weak) UITextField *groupCodeTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) NSString *groupCode;

@property (nonatomic) NSUInteger intervalLengthInMinutes; //use this later


@end

@implementation CreateScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
