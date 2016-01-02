//
//  Constants.h
//  Tent
//
//  Created by Jeremy on 9/19/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject


// Person ParseObject
#define kPersonClassName                        @"Person"

#define kPersonPropertyAssignmentsArray                 @"assignmentsArray"
#define kPersonPropertyAssociatedUser                   @"associatedUser"
#define kPersonPropertyOfflineName                      @"offlineName"

// GroupSchedule ParseObject
#define kGroupScheduleClassName                 @"GroupSchedule"

#define kGroupSchedulePropertyGroupName                 @"groupName"
#define kGroupSchedulePropertyGroupCode                 @"groupCode"
#define kGroupSchedulePropertyStartDate                 @"startDate"
#define kGroupSchedulePropertyEndDate                   @"endDate"
#define kGroupSchedulePropertyHomeGame                  @"homeGame"
#define kGroupSchedulePropertyPersonsInGroup            @"personsInGroup"
#define kGroupSchedulePropertyCreatedBy                 @"createdBy" 
#define kGroupSchedulePropertyAssignmentsGenerated      @"assignmentsGenerated"
#define kGroupSchedulePropertyNumIntervals              @"numIntervals"
/* V2
#define kGroupSchedulePropertyIntervalLengthInMinutes   @"intervalLengthInMinutes"
#define kGroupSchedulePropertyAdmins                    @"admins"
#define kGroupSchedulePropertyPrivacy                   @"privacy"
 */

// User ParseObject
#define kParsePropertyObjectId                  @"objectId"
#define kParsePropertyCreatedAt                 @"createdAt"

#define kUserPropertyClassName                  @"_User" //use [PFUser query] instead

#define kUserPropertyGroupSchedules                     @"groupSchedules"
#define kUserPropertyFullName                           @"additional"

// HomeGame ParseObject
#define kHomeGameClassName                      @"HomeGame"

#define kHomeGamePropertyOpponent                       @"opponent"
#define kHomeGamePropertyGameTime                       @"gameTime"
#define kHomeGamePropertyConferenceGame                 @"conferenceGame"
#define kHomeGamePropertyExhibition                     @"exhibition"
#define kHomeGamePropertyIndex                          @"index"


#define kUserDefaultsHomeGamesData                      @"homeGamesData"

#define kPrivacyValuePrivate                    @"private"
#define kPrivacyValuePublic                     @"public"

// Container View Controller Children Storyboard Identifiers
#define kChildViewControllerMe                  @"ChildViewControllerMe"
#define kChildViewControllerCurrent             @"ChildViewControllerCurrent"
#define kChildViewControllerOthers              @"ChildViewControllerOthers"
#define kChildViewControllerTimeSlots           @"ChildViewControllerTimeSlots"

// Notifications to keep schedule object consistent across vcs
#define kNotificationNameScheduleChanged        @"scheduleChanged"
#define kUserInfoLocalScheduleKey                       @"schedule"
#define kUserInfoLocalScheduleChangedPropertiesKey             @"changedProperties"
#define kUserInfoLocalSchedulePropertyPersonsArray      @"personsArray"
#define kUserInfoLocalSchedulePropertyGroupName         @"groupName"
#define kUserInfoLocalSchedulePropertyOther             @"other"

+(NSString *)formatDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatDateAndTime: (NSDate *)date withDateStyle:(NSDateFormatterStyle)dateStyle timeStyle: (NSDateFormatterStyle)timeStyle;

/*
+(NSString *)formatWeekday:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatDateOnly:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatWeekdayDateTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatWeekdayDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatDateTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
*/


+(NSUInteger)overallRowForIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;
+(NSIndexPath *)indexPathForOverallRow:(NSUInteger)overallRow tableView:(UITableView *)tableView;

@end
