//
//  Schedule.h
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

@property(nonatomic) NSUInteger numPeople;
@property(nonatomic) NSUInteger numIntervals;

+(NSUInteger)numIntervalsStatic;
@end
