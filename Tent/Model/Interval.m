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

-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate section:(NSUInteger)section
{
    self = [super init];
    if(self){
        self.startDate = startDate;
        self.endDate = endDate;
        self.section =  section;
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
    self.timeString =timeString;
    self.dateTimeString = [[dateString stringByAppendingString:@" "]stringByAppendingString:timeString];
}


@end

