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


//TODO: implement. consecutive only matters within each day
-(void)calculateConsecutiveFutureDayIntervalsAvailableArray
{
    //need to know Day and interval within Day
}
/*
-(NSUInteger)consecutivePreviousDayIntervalsAssigned{
    if(self.currentOverallIntervalIndexForInitialDayAssignments == 0) return 0;
    NSUInteger count=0;
    for(NSInteger i = (self.currentOverallIntervalIndexForInitialDayAssignments - 1); i>=0; i++){
        if(count >= 6){
            
        }
        if([self isAssignedInIntervalOverallIndex:i]){
            count++;
        }else{
            return count;
        }
    }
    return count;
}

-(NSUInteger)consecutiveFutureDayIntervalsAvailable
{
    NSUInteger count=0;
    if(self.currentOverallIntervalIndexForInitialDayAssignments == self.assignmentsArray.count - 1) return 0;
    for(NSInteger i = (self.currentOverallIntervalIndexForInitialDayAssignments + 1); i < self.assignmentsArray.count; i++){
        if([self isAvailableButNotAssignedInIntervalOverallIndex:i]){
            count++;
        }else{
            return count;
        }
    }
    return count;
    
}
 */
 
-(BOOL)isAvailableInCurrentOverallInterval
{
    return [self isAvailableInIntervalOverallIndex:self.currentOverallIntervalIndexForInitialDayAssignments];
}

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

#pragma mark - Copy

-(id)copyWithZone:(NSZone *)zone
{
    Person *copy  = [[self class]allocWithZone:zone];
    if(copy){
        copy.assignmentsArray = [self.assignmentsArray mutableCopy];
        copy.scheduleIndex = self.scheduleIndex;
    }
    return copy;
}



@end
