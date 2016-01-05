//
//  AlgorithmSchedule.h
//  Tent
//
//  Created by Jeremy on 11/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlgorithmSchedule : NSObject


-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate intervalLengthInMinutes: (NSUInteger)intervalLength assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numIntervals:(NSUInteger)numIntervals;

-(NSMutableArray *)generateAssignments;
-(BOOL)checkForError;

@end
