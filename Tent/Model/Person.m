//
//  Person.m
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Person.h"
@interface Person()

@property (nonatomic) NSUInteger numIntervals;

@end

@implementation Person

-(NSUInteger)numIntervals
{
    return [self.assignmentsArray count];
}

#pragma mark - Init

-(instancetype)initWithUser:(PFUser *)user assignmentsArray:(NSMutableArray *)assignments scheduleIndex:(NSUInteger)index parseObjectID:(NSString *)parseObjectID
{
    self = [super init];
    if(self) {
        self.user = user;
        self.assignmentsArray = assignments;
        self.scheduleIndex = index;
        self.parseObjectID = parseObjectID;
        
    }
    return self;
}

-(instancetype)initWithUser:(PFUser *)user numIntervals: (NSUInteger)numIntervals
{
    self = [super init];
    if(self) {
        self.user = user;
        [self initializeAssignmentsArrayWithNumIntervals: numIntervals];
    }
    return self;
}

-(void)initializeAssignmentsArrayWithNumIntervals:(NSUInteger) numIntervals
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(int i = 0; i<numIntervals;i++){
        [array addObject:[NSNumber numberWithInteger:0]];
    }
    self.assignmentsArray = array;
}

#pragma mark - Resets

-(void)clearAssignments
{
    for(int i = 0; i<[self.assignmentsArray count];i++){
        if([self.assignmentsArray[i] integerValue] == 2){
            self.assignmentsArray[i] = @1;
        }
    }
}

-(void)clearAvailablities
{
    for(int i = 0; i<[self.assignmentsArray count];i++){
        self.assignmentsArray[i] = @0;
    }
}

#pragma mark - Equality

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    //NSLog(@"IS Equal");
    return [self isEqualToPerson:other];
}

- (BOOL)isEqualToPerson:(Person *)aPerson {
    if (self == aPerson)
        return YES;
    if (![[(id)[self user] objectId] isEqual:[[aPerson user] objectId]])
        return NO;
    if (!([self scheduleIndex] == [aPerson scheduleIndex]))
        return NO;
    if (![(id)[self assignmentsArray] isEqual:[aPerson assignmentsArray]])
        return NO;
    if (![(id)[self parseObjectID] isEqual:[aPerson parseObjectID]])
        return NO;
    // NSLog(@"Test equality");
    return YES;
}


@end
