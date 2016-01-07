//
//  Person.h
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface Person : NSObject <NSCopying>

@property (nonatomic) NSMutableArray *assignmentsArray;
@property (nonatomic) PFObject *user;
@property (nonatomic) NSString *parseObjectID;
@property (nonatomic) NSString *offlineName;

@property (nonatomic) NSUInteger scheduleIndex; //for algorithm

-(instancetype)initWithUser:(PFObject *)user assignmentsArray:(NSMutableArray *)assignments scheduleIndex:(NSUInteger)index parseObjectID:(NSString *)parseObjectID;
-(instancetype)initWithUser:(PFObject *)user numIntervals: (NSUInteger)numIntervals;

@end
