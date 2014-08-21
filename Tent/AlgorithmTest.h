//
//  AlgorithmTest.h
//  Tent
//
//  Created by Jeremy on 8/18/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlgorithmTest : NSObject



// Basic Parameters
@property(nonatomic) NSUInteger numPeople;
@property(nonatomic) NSUInteger numIntervals;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

// Matrix Schedules 
@property (nonatomic) NSMutableArray *availabilitiesSchedule;
@property (nonatomic) NSMutableArray *assignmentsSchedule;


-(void)setup;
@end
