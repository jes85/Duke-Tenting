//
//  AlgorithmScheduleOld.h
//  Tent
//
//  Created by Jeremy on 1/6/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlgorithmScheduleOld : NSObject

-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate intervalLengthInMinutes: (NSUInteger)intervalLength assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numIntervals:(NSUInteger)numIntervals;

-(NSMutableArray *)generateAssignments;
-(BOOL)checkForError;

@end
