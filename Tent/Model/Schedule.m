//
//  Schedule.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Schedule.h"

@implementation Schedule

-(NSUInteger)numPeople
{
    if(!_numPeople) _numPeople = 12;
    return _numPeople;
}

-(NSUInteger)numIntervals{
    if(!_numIntervals) _numIntervals=10;
    return _numIntervals;
}


+(NSUInteger)numIntervalsStatic{
    return 10;
}
@end
