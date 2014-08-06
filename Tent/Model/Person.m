//
//  Person.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Person.h"

@implementation Person

-(NSMutableArray *)availabilitiesArray
{
    if(!_availabilitiesArray) _availabilitiesArray = [[NSMutableArray alloc]init];
    return _availabilitiesArray;
}
-(NSMutableArray *)assignmentsArray
{
    if(!_assignmentsArray)_assignmentsArray = [[NSMutableArray alloc]init];
    return _assignmentsArray;
}
-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index  numIntervals:(NSUInteger)numIntervals
{
    self = [super init];
    if(self){
        self.name = name;
        self.indexOfPerson = index;
        self.availabilitiesArray = [self createZerosArrayWithNumIntervals:numIntervals];
        self.assignmentsArray = [self createZerosArrayWithNumIntervals:numIntervals];
    }
    return self;
}

-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index availabilitiesArray:(NSMutableArray *)availArray
{
    self = [super init];
    if(self){
        self.name = name;
        self.indexOfPerson = index;
        self.availabilitiesArray = availArray;
        self.assignmentsArray = [self createZerosArray];
    }
    return self;
}

-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index availabilitiesArray:(NSMutableArray *)availArray assignmentsArray:(NSMutableArray *)assignArray
{
    self = [super init];
    if(self){
        self.name = name;
        self.indexOfPerson = index;
        self.availabilitiesArray = availArray;
        self.assignmentsArray = assignArray;
    }
    return self;
}

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
    if (![(id)[self name] isEqual:[aPerson name]])
        return NO;
    if (!([self indexOfPerson] == [aPerson indexOfPerson]))
        return NO;
    if (![(id)[self availabilitiesArray] isEqual:[aPerson availabilitiesArray]])
        return NO;
    if (![(id)[self assignmentsArray] isEqual:[aPerson assignmentsArray]])
        return NO;
   // NSLog(@"Test equality");
    return YES;
}

-(NSMutableArray *)createZerosArray
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(int i = 0; i<[self.availabilitiesArray count];i++){
        [array addObject:@0];
    }
    return array;
}
-(NSMutableArray *)createZerosArrayWithNumIntervals:(NSUInteger)numIntervals
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(int i = 0; i<numIntervals;i++){
        [array addObject:@0];
    }
    return array;
}

@end
