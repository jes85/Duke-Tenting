//
//  Schedule.h
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

// init
    -(instancetype)initWithNumPeople:(NSUInteger)numPeople withNumIntervals:(NSUInteger)numIntervals;
    -(instancetype)initWithAvailabilitiesSchedule:(NSMutableArray *)availSchedule;

    -(void)setup;

// Basic Parameters
    @property(nonatomic) NSUInteger numPeople;
    @property(nonatomic) NSUInteger numIntervals;

// Schedule (make this private later?)
    @property (nonatomic) NSMutableArray *availabilitiesSchedule;
    @property (nonatomic) NSMutableArray *assignmentsSchedule;



//Testing
+(NSUInteger)testNumPeople;
+(NSUInteger)testNumIntervals;


@end
