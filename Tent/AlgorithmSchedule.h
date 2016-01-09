//
//  AlgorithmSchedule.h
//  Tent
//
//  Created by Jeremy on 11/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schedule.h"

@interface AlgorithmSchedule : NSObject

-(instancetype)initWithSchedule:(Schedule *)schedule;

-(NSMutableArray *)generateAssignments;
-(BOOL)checkForError;
-(void)makeAlgorithmWorkEvenThoughNotAllRequiredPersonsAreAvailable;
@end
