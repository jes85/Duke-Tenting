//
//  AdminToolsViewController.h
//  Tent
//
//  Created by Jeremy on 12/24/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"
@interface AdminToolsViewController : UIViewController


@property (nonatomic) Schedule *schedule;


+(void)updateParsePersons:(NSMutableArray *)parsePersonIds WithNewAssignmentsArrays:(NSMutableArray *)assignmentsArrays completion:(void(^)(void))callback;
+(void)updateParseSchedule:(NSString *)parseGroupScheduleId WithDictionary:(NSDictionary *)dictionary completion:(void(^)(void))callback;
@end
