//
//  Interval.m
//  Tent
//
//  Created by Jeremy on 8/4/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Interval.h"
#import "Constants.h"

@interface Interval ()
@end

@implementation Interval

-(NSMutableArray *)availablePersons
{
    if(!_availablePersons)_availablePersons = [[NSMutableArray alloc]init];
    return _availablePersons;
}

-(NSMutableArray *)assignedPersons
{
    if(!_assignedPersons)_assignedPersons = [[NSMutableArray alloc]init];
    return _assignedPersons;
}

-(instancetype)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate section:(NSUInteger)section availablePersons:(NSMutableArray *)available assignedPersons:(NSMutableArray *)assigned
{
    self = [super init];
    if(self){
        self.startDate = startDate;
        self.endDate = endDate;
        self.section =  section;
        self.availablePersons = available;
        self.assignedPersons = assigned;
        [self createIntervalDateTimeStrings];
    }
    return self;
}

-(void)createIntervalDateTimeStrings
{
    NSString *start = [Constants formatTime:self.startDate withStyle:NSDateFormatterShortStyle];
    NSString *end = [Constants formatTime:self.endDate withStyle:NSDateFormatterShortStyle];
    NSString *timeString = [[start stringByAppendingString:@" - "]stringByAppendingString:end];
    NSString *dateString = [Constants formatDate:self.startDate withStyle:NSDateFormatterShortStyle];
    self.timeString = timeString;
    self.dateTimeString = [[dateString stringByAppendingString:@" "]stringByAppendingString:timeString];
}


//TODO: unit test
-(BOOL)containsDate:(NSDate *)date
{
    return ([date timeIntervalSinceDate:self.startDate] >= 0 && [date timeIntervalSinceDate:self.endDate] <= 0);
}


-(id)copyWithZone:(NSZone *)zone
{
    Interval *copy  = [[self class]allocWithZone:zone];
    if(copy){
        copy.assignedPersons = [self.assignedPersons mutableCopy];
        copy.availablePersons = [self.availablePersons mutableCopy];
        copy.startDate = self.startDate;
        copy.endDate = self.endDate;
        copy.timeString = self.timeString;
        copy.dateTimeString = self.dateTimeString;
        copy.requiredPersons = self.requiredPersons;
        copy.night = self.night;
    }
    return copy;
}

@end

