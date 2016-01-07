//
//  AlgorithmPerson.h
//  Tent
//
//  Created by Jeremy on 1/6/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface AlgorithmPerson : NSObject

// General
@property (nonatomic) NSMutableArray *assignmentsArray;
@property (nonatomic) NSUInteger scheduleIndex;

// Initial Assignment Sort Descriptors
@property (nonatomic) NSUInteger currentOverallIntervalIndex;
@property (nonatomic) NSUInteger consecutivePreviousIntervalsAssigned;
@property (nonatomic) NSUInteger consecutiveFutureIntervalsAvailable;
@property (nonatomic) NSUInteger totalNumIntervalsAssigned;
@property (nonatomic) BOOL lessThanIdealSlotsAvailable;

// Sums
@property (nonatomic) float idealNumNightIntervalsAssigned;
@property (nonatomic) float idealNumDayIntervalsAssigned;

@property (nonatomic) NSUInteger numNightIntervalsAssigned;
@property (nonatomic) NSUInteger numDayIntervalsAssigned;


// Init
-(instancetype)initWithPerson:(Person *)person scheduleIndex:(NSUInteger)scheduleIndex;

// Convenience Methods
-(BOOL)isAvailableButNotAssignedInIntervalOverallIndex:(NSUInteger)intervalIndex;
-(BOOL)isAssignedInIntervalOverallIndex:(NSUInteger)intervalIndex;
-(BOOL)isAvailableInIntervalOverallIndex:(NSUInteger)intervalIndex;

@end
