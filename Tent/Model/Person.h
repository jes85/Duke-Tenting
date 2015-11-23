//
//  Person.h
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface Person : NSObject

@property (nonatomic) NSMutableArray *assignmentsArray;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSUInteger scheduleIndex;
@property (nonatomic) NSString *parseObjectID;


-(instancetype)initWithUser:(PFUser *)user assignmentsArray:(NSMutableArray *)assignments scheduleIndex:(NSUInteger)index parseObjectID:(NSString *)parseObjectID;
-(instancetype)initWithUser:(PFUser *)user numIntervals: (NSUInteger)numIntervals;

@end
