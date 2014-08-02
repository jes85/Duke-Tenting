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
-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index availabilitiesArray:(NSMutableArray *)array
{
    self = [super init];
    if(self){
        self.name = name;
        self.indexOfPerson = index;
        self.availabilitiesArray = array;
    }
    return self;
}

@end
