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


@end
