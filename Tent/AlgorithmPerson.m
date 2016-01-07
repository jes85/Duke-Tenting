//
//  AlgorithmPerson.m
//  Tent
//
//  Created by Jeremy on 1/6/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import "AlgorithmPerson.h"
#import "Interval.h"

@interface AlgorithmPerson()

// Initial Assignment Sort Descriptors
@property (nonatomic) NSUInteger consecutivePreviousIntervalsAssigned;
@property (nonatomic) NSUInteger consecutiveFutureIntervalsAvailable;
@property (nonatomic) NSUInteger totalNumIntervalsAssigned;
@property (nonatomic) BOOL lessThanIdealSlotsAvailable;


@property (nonatomic) float ideaNumlNightIntervalsAssigned;
@property (nonatomic) float idealNumDayIntervalsAssigned;

@property (nonatomic) NSUInteger numNightIntervalsAssigned;
@property (nonatomic) NSUInteger numDayIntervalsAssigned;

@property (nonatomic) NSUInteger currentOverallIntervalIndex;


@end

@implementation AlgorithmPerson

-(instancetype)initWithPerson:(Person *)person scheduleIndex:(NSUInteger)scheduleIndex
{
    self = [super init];
    if(self){
        self.assignmentsArray = person.assignmentsArray;
        self.scheduleIndex = scheduleIndex;
    }
    return self;
}


/*
-(NSUInteger)consecutivePreviousIntervalsAssigned{
    if(self.currentOverallIntervalIndex == 0) return 0;
    NSUInteger count=0;
    for(NSInteger i = (self.currentOverallIntervalIndex - 1); i>=0; i++){
        if([self isAssignedInIntervalOverallIndex:i]){
            count++;
        }else{
            return count;
        }
    }
    return count;
}

-(NSUInteger)consecutiveFutureIntervalsAvailable
{
    NSUInteger count=0;
    if(self.currentOverallIntervalIndex == self.assignmentsArray.count - 1) return 0;
    for(NSInteger i = (self.currentOverallIntervalIndex + 1); i < self.assignmentsArray.count; i++){
        if([self isAvailableButNotAssignedInIntervalOverallIndex:i]){
            count++;
        }else{
            return count;
        }
    }
    return count;
    
}
 */


-(BOOL)isAvailableButNotAssignedInIntervalOverallIndex:(NSUInteger)intervalIndex
{
    if([self.assignmentsArray[intervalIndex] integerValue] == 1){
        return YES;
    }else{
        return NO;
    }
}
-(BOOL)isAssignedInIntervalOverallIndex:(NSUInteger)intervalIndex
{
    if([self.assignmentsArray[intervalIndex] integerValue] == 2){
        return YES;
    }else{
        return NO;
    }
}
-(BOOL)isAvailableInIntervalOverallIndex:(NSUInteger)intervalIndex
{
    if([self.assignmentsArray[intervalIndex] integerValue] == 1 ||  [self.assignmentsArray[intervalIndex] integerValue] == 2) {
        return YES;
    }else{
        return NO;
    }
}

@end
