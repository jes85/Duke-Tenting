//
//  IntervalsDisplayData.h
//  Tent
//
//  Created by Jeremy on 10/9/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntervalsDisplayData : NSObject

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSUInteger intervalLengthInMinutes;

@property (nonatomic) NSArray *intervalDisplayArray;
@property (nonatomic) NSUInteger numDays;
@property (nonatomic) NSUInteger numIntervals;


-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate intervalLengthInMinutes:(NSUInteger)intervalLength;
@end
