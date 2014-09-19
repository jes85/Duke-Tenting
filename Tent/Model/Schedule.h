//
//  Schedule.h
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

// init (clean this up later)
-(instancetype)initWithNumPeople:(NSUInteger)numPeople numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
-(instancetype)initWithNumPeople:(NSUInteger)numPeople withNumIntervals:(NSUInteger)numIntervals;
//designated initializer
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex;
//change this to be designated initializer
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex parseObjectID: (NSString *)parseObjectID;

-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
-(instancetype)initWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate;


-(void)setup;

// Basic Parameters
@property(nonatomic) NSUInteger numPeople;
@property(nonatomic) NSUInteger numIntervals;
@property(nonatomic) NSUInteger numHourIntervals;//convert to numIntervals and add property that specifies interval range (hour)
@property (nonatomic, ) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSString *name; //for parse
@property (nonatomic) NSMutableArray *intervalArray; //Interval[]
@property (nonatomic)NSArray *hourIntervalsDisplayArray;
@property (nonatomic) NSString *privacy;
@property (nonatomic) NSString *password; //how to encrypt this?
@property (nonatomic) NSUInteger homeGameIndex;
@property (nonatomic) NSString *parseObjectID;

// Matrix Schedules (make these private later?)
    @property (nonatomic) NSMutableArray *availabilitiesSchedule;
    @property (nonatomic) NSMutableArray *assignmentsSchedule;



-(NSMutableArray *)createZeroedIntervalArray;


@end
