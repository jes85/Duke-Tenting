//
//  IntervalsDisplayData.m
//  Tent
//
//  Created by Jeremy on 10/9/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "IntervalsDisplayData.h"

@implementation IntervalsDisplayData
-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate intervalLengthInMinutes:(NSUInteger)intervalLength
{
    self = [super init];
    if(self){
        self.startDate = startDate;
        self.endDate = endDate;
        self.intervalLengthInMinutes = intervalLength;
        [self generateDisplayArray];
    }
    return self;
}

-(void)generateDisplayArray
{
    NSTimeInterval seconds = [self.endDate timeIntervalSinceDate:self.startDate];
    double numIntervals = seconds*60/self.intervalLengthInMinutes;

    //get numDays from date components (this equals number of sections)
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *datedifferenceComponents = [calendar components:NSCalendarUnitDay fromDate:self.startDate toDate:self.endDate options:nil];
    NSDateComponents *startDateComponents = [calendar components:NSCalendarUnitHour fromDate:self.startDate];
    NSDateComponents *endDateComponents = [calendar components:NSCalendarUnitHour fromDate:self.endDate];

    
    self.numDays = datedifferenceComponents.day;
    //get numIntervals in Day 1 from start Date
    NSUInteger numIntervalsDay1 = 24 - startDateComponents.hour;
    //get numIntervals in last day from end date
    NSUInteger numIntervalsLastDay = endDateComponents.hour;
    
    //get numIntervals in all days in between from intervalLength
    NSUInteger numIntervalsNormalDay = 24*60/self.intervalLengthInMinutes;
    
    
    
}
@end
