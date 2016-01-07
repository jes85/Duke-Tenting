//
//  AlgorithmInterval.m
//  Tent
//
//  Created by Jeremy on 1/6/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import "AlgorithmInterval.h"

@implementation AlgorithmInterval

-(instancetype)initWithInterval:(Interval *)interval overallIndex:(NSUInteger)overallIndex
{
    self = [super init];
    if(self){
        self.requiredPersons = interval.requiredPersons;
        self.night = interval.night;
        self.overallIndex = overallIndex;
    }
    return self;
}


@end
