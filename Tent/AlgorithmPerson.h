//
//  AlgorithmPerson.h
//  Tent
//
//  Created by Jeremy on 1/6/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface AlgorithmPerson : NSObject

@property (nonatomic) NSMutableArray *assignmentsArray;
@property (nonatomic) NSUInteger scheduleIndex;

-(instancetype)initWithPerson:(Person *)person scheduleIndex:(NSUInteger)scheduleIndex;

@end
