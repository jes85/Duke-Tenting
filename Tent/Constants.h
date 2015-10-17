//
//  Constants.h
//  Tent
//
//  Created by Jeremy on 9/19/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#define kPersonClassName    @"Person"

#define kPersonPropertyName                 @"name"
#define kPersonPropertyIndex                @"index"
#define kPersonPropertyAvailabilitiesArray  @"availabilitiesArray"
#define kPersonPropertyAssignmentsArray     @"assignmentsArray"
#define kPersonPropertyAssociatedSchedule   @"associatedSchedule" //or schedule name?


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
#define kSchedulePropertyCreatedBy              @"createdBy" //be careful of strong reference cycle
#define kSchedulePropertyPersonsList            @"personsList"

#define kPrivacyValuePrivate                    @"private"
#define kPrivacyValuePublic                     @"public"

#define kUserPropertySchedulesList              @"schedulesList"

#define kUserPropertyFullName                   @"additional"

#define kChildViewControllerMe                  @"ChildViewControllerMe"
#define kChildViewControllerCurrent                 @"ChildViewControllerCurrent"
#define kChildViewControllerOthers              @"ChildViewControllerOthers"
#define kChildViewControllerTimeSlots           @"ChildViewControllerTimeSlots"

#define kUserDefaultsHomeGamesData                          @"homeGamesData"

+(NSString *)formatDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style;

/*
+(NSString *)formatWeekday:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatDateOnly:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatWeekdayDateTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatWeekdayDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+(NSString *)formatDateTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
*/

@end
