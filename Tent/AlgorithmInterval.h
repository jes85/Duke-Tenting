//
//  AlgorithmInterval.h
//  Tent
//
//  Created by Jeremy on 1/6/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Interval.h"
@interface AlgorithmInterval : NSObject

@property (nonatomic) NSUInteger requiredPersons; //for UNC //make UNCInterval subclass
@property (nonatomic) BOOL night;
@property (nonatomic) NSUInteger overallIndex; //only for Algorithm

-(instancetype)initWithInterval:(Interval *)interval overallIndex:(NSUInteger)overallIndex;

@end
