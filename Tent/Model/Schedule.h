//
//  Schedule.h
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "HomeGame.h"


@interface Schedule : NSObject

// Init
-(instancetype)initWithGroupName:(NSString *)name groupCode:(NSString *)groupCode startDate:(NSDate *)startDate endDate:(NSDate *)endDate intervalLengthInMinutes: (NSUInteger)intervalLength personsArray:(NSMutableArray *)personsArray homeGame:(HomeGame *)hg createdBy:(PFObject *)createdBy assignmentsGenerated:(BOOL)assignmentsGenerated parseObjectID:(NSString *)parseObjectID;

// Basic Info
@property (nonatomic) NSString *groupName;
@property (nonatomic) NSString *groupCode;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSUInteger intervalLengthInMinutes;
@property (nonatomic) NSUInteger numIntervals;
@property (nonatomic) NSUInteger requiredPersonsPerInterval; //for non-UNC schedules
@property (nonatomic) BOOL assignmentsGenerated;
@property (nonatomic) NSString *parseObjectID;
//@property (nonatomic) NSUInteger currentUserPersonIndex; //TODO: might want to make this a method instead of a property. not sure if it initializes properly if schedule is initiated without a personsArray
-(NSUInteger)findCurrentUserPersonIndex;
@property (nonatomic) BOOL currentUserWasRemoved;


// Relationships
@property (nonatomic) NSMutableArray *personsArray; 
@property (nonatomic) PFObject *createdBy;
@property (nonatomic) HomeGame *homeGame;


// UI Helper Arrays
-(void)resetIntervalArray;
-(void)createIntervalDataArrays; //Add KVO for self.intervalDataArrays to update every time personsArrays are changed
@property (nonatomic) NSMutableArray *intervalDataByOverallRow; // [Interval, Interval,...]
@property (nonatomic) NSMutableDictionary *intervalDataBySection; //TODO: see if i need both of these

/*
 { 
    sectionIndex: {
             day: NSDate
             sectionHeader: NSString
             intervalStartIndex: NSUInteger
             intervalEndIndex: NSUInteger 
    }
 }
 
 
 Notes:
    if contains intervals 0,1,2,3,4, start = 0, end = 5
    numIntervalsBeforeDay: startIndex
    numIntervalsInDay: endIndex - startIndex

 */





/* V2

@property (nonatomic) NSString *privacy;
@property (nonatomic) NSMutableArray *admins;


*/






// Formatting
-(NSString *)dateStringForSection:(NSUInteger)section;
-(NSString *)timeStringForIndexPath:(NSIndexPath *)indexPath;
-(NSString *)dateTimeStringForIndexPath:(NSIndexPath *)indexPath;

// Stats

-(void)calculateNumIntervalsEachPersonIsAvailableAndAssigned;
-(NSMutableArray *)numIntervalsEachPersonIsAvailable;
-(NSMutableArray *)numIntervalsEachPersonIsAssigned;

-(void)calculateNumPeopleAvailableAndAssignedInEachInterval;
-(NSMutableArray *)numPeopleAvailableInEachInterval;
-(NSMutableArray *)numPeopleAssignedInEachInterval;

-(NSUInteger)numPeopleAvailableInIntervalIndex:(NSUInteger)intervalIndex;
-(NSUInteger)numPeopleAssignedInIntervalIndex:(NSUInteger)intervalIndex;



@end
