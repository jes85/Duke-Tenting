//
//  IntervalTest.m
//  Duke Tenting
//
//  Created by Jeremy on 11/1/16.
//  Copyright © 2016 Jeremy Schreck. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Interval.h"
#import "Schedule.h"

@interface IntervalTest : XCTestCase

@end

@implementation IntervalTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSDate *startDate = [[NSDate alloc]initWithTimeIntervalSinceNow:-60*60*24];
    NSDate *endDate = [[NSDate alloc]initWithTimeInterval:60*60*24*7 sinceDate:startDate];
    Schedule *schedule = [[Schedule alloc]initWithGroupName:@"groupName" groupCode:@"groupCode" startDate:startDate endDate:endDate intervalLengthInMinutes:60 personsArray:nil homeGame:nil createdBy:nil assignmentsGenerated:nil parseObjectID:nil];
    NSDate *expectedFirstIntervalDate = [[NSDate alloc]initWithTimeInterval:0 sinceDate:startDate];
    Interval *firstInterval = schedule.intervalDataByOverallRow[0];
    Interval *secondInterval = schedule.intervalDataByOverallRow[1];

    XCTAssert([firstInterval containsDate:expectedFirstIntervalDate]);
    expectedFirstIntervalDate = [[NSDate alloc]initWithTimeInterval:30*60 sinceDate:startDate];
    XCTAssert([firstInterval containsDate:expectedFirstIntervalDate]);

    expectedFirstIntervalDate = [[NSDate alloc]initWithTimeInterval:59*60*60 sinceDate:startDate];
    XCTAssert([firstInterval containsDate:expectedFirstIntervalDate]);

    NSDate *expectedSecondIntervalDate = [[NSDate alloc]initWithTimeInterval:60*60*60 sinceDate:startDate];
    XCTAssert(![firstInterval containsDate:expectedSecondIntervalDate]);
    XCTAssert(![secondInterval containsDate:expectedSecondIntervalDate]);

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
