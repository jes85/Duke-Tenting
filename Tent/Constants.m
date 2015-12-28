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

+(NSString *)formatDateAndTime: (NSDate *)date withDateStyle:(NSDateFormatterStyle)dateStyle timeStyle: (NSDateFormatterStyle)timeStyle

{
    return [[[Constants formatDate:date withStyle:dateStyle] stringByAppendingString:@" "] stringByAppendingString:[Constants formatTime:date withStyle:timeStyle]];
}


//TODO: these methods should be based off model, not table view
+(NSUInteger)overallRowForIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSUInteger overallRow = indexPath.row;
    for(int i = 0; i<indexPath.section; i++){
        overallRow += [tableView numberOfRowsInSection:i];
    }
    return overallRow;
}

+(NSIndexPath *)indexPathForOverallRow:(NSUInteger)overallRow tableView:(UITableView *)tableView
{
    NSUInteger rowCount = 0;
    NSUInteger section = 0;
    
    while(rowCount + [tableView numberOfRowsInSection:section] - 1 < overallRow){
        rowCount += [tableView numberOfRowsInSection:section];
        section = section + 1;
    }
    
    NSInteger row = overallRow - rowCount;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}



@end
