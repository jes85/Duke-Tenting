//
//  Interval.m
//  Tent
//
//  Created by Jeremy on 8/4/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Interval.h"

@implementation Interval

-(NSMutableArray *)availablePersons
{
    if(!_availablePersons)_availablePersons = [[NSMutableArray alloc]init];
    return _availablePersons;
}

-(NSMutableArray *)assignedPersons
{
    if(!_assignedPersons)_assignedPersons = [[NSMutableArray alloc]init];
    return _assignedPersons;
}

-(instancetype)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}



@end

