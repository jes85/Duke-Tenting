//
//  Schedule.h
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface Schedule : NSObject
//TODO: separate schedule object used to store in parse and schedule object used for algorithm into 2 separate classes

// init

//designated initializer
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex parseObjectID: (NSString *)parseObjectID;

//no parseObject ID (when schedule hasn't been saved yet)
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex;

//init for CreateScheduleViewController.m
-(instancetype)initWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex;


//new initializers
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex creator:(PFUser *)creator parseObjectID: (NSString *)parseObjectID;
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex admins:(NSArray *)admins parseObjectID: (NSString *)parseObjectID;

-(BOOL)setup;

// Basic Parameters
@property(nonatomic) NSUInteger numPeople;
@property(nonatomic) NSUInteger numIntervals;
@property(nonatomic) NSUInteger numHourIntervals;//convert to numIntervals and add property that specifies interval range (hour)
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSString *name; //for parse
@property (nonatomic) NSMutableArray *personsArray;

@property (nonatomic) NSMutableArray *intervalDataByOverallRow;
@property (nonatomic) NSMutableDictionary *intervalDataBySection;

//@property (nonatomic) NSMutableArray *intervalArray; //Interval[]
//@property (nonatomic) NSDictionary *intervalsDisplayData;


@property (nonatomic) NSString *privacy;
@property (nonatomic) NSString *password; //how to encrypt this?
@property (nonatomic) NSUInteger homeGameIndex;
@property (nonatomic) NSString *creatorObjectID;
@property (nonatomic) NSString *creatorName;
@property (nonatomic) NSUInteger currentUserPersonIndex;
@property (nonatomic) NSString *opponent; // or Home Game
@property (nonatomic) NSString *parseObjectID;

// Matrix Schedules (make these private later?)
    @property (nonatomic) NSMutableArray *availabilitiesSchedule;
    @property (nonatomic) NSMutableArray *assignmentsSchedule;


-(void)resetIntervalArray;


//Formatting
-(NSString *)dateStringForSection:(NSUInteger)section;
-(NSString *)timeStringForIndexPath:(NSIndexPath *)indexPath;
-(NSString *)dateTimeStringForIndexPath:(NSIndexPath *)indexPath;

@end
