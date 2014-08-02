//
//  Person.h
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic) NSMutableArray *availabilitiesArray;

@property (nonatomic) NSMutableArray *assignmentsArray;
@property (nonatomic) NSString *name;
@property (nonatomic) NSUInteger indexOfPerson;


-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index availabilitiesArray:(NSMutableArray *)array;

@end
