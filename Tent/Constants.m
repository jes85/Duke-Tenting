//
//  Constants.m
//  Tent
//
//  Created by Jeremy on 9/19/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Constants.h"

@implementation Constants


+(NSString *)formatDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:style];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSUInteger weekdayNum = [comps weekday];
    NSString *weekday = [[dateFormatter shortWeekdaySymbols][weekdayNum-1] stringByAppendingString:@". "];
    NSString *dateLabelText = [weekday stringByAppendingString:[dateFormatter stringFromDate:date]];
    
    return dateLabelText;
}

+(NSString *)formatTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style
{
    // Time
    NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc]init];
    [timeDateFormatter setTimeStyle:style];
    NSString *timeLabelText = [timeDateFormatter stringFromDate:date];
    
    return timeLabelText;
}


@end
