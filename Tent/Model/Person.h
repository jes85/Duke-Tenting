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
@property (nonatomic) NSString *scheduleName;


//Clear these inits up and designate one

-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index numIntervals:(NSUInteger)numIntervals scheduleName:(NSString *)scheduleName;
-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index availabilitiesArray:(NSMutableArray *)availArray scheduleName:(NSString *)scheduleName;
-(instancetype)initWithName: (NSString *)name index:(NSUInteger)index availabilitiesArray:(NSMutableArray *)availArray assignmentsArray:(NSMutableArray *)assignArray scheduleName:(NSString *)scheduleName;

@end
