//
//  Schedule.h
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

// init (clean this up later)
-(instancetype)initWithNumPeople:(NSUInteger)numPeople numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
-(instancetype)initWithNumPeople:(NSUInteger)numPeople withNumIntervals:(NSUInteger)numIntervals;

-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
-(instancetype)initWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate;


-(void)setup;

// Basic Parameters
@property(nonatomic) NSUInteger numPeople;
@property(nonatomic) NSUInteger numIntervals;
@property(nonatomic) NSUInteger numHourIntervals;
@property (nonatomic, ) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSString *name; //for parse
@property (nonatomic) NSMutableArray *intervalArray; //Interval[]
@property (nonatomic)NSArray *hourIntervalsDisplayArray;

// Matrix Schedules (make these private later?)
    @property (nonatomic) NSMutableArray *availabilitiesSchedule;
    @property (nonatomic) NSMutableArray *assignmentsSchedule;






@end
