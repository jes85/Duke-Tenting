//
//  UNCAlgorithmSchedule.m
//  Tent
//
//  Created by Jeremy on 1/6/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import "UNCAlgorithmSchedule.h"

@implementation UNCAlgorithmSchedule


//change for UNC
/*
-(instancetype)initWithSchedule:(Schedule *)schedule
{
    self = [super init];
    if(self){
        self.intervalDataByOverallRow = schedule.intervalDataByOverallRow;
        self.personsArray = schedule.personsArray;
        self.numIntervals = schedule.intervalDataByOverallRow.count;
        self.numPeople = schedule.personsArray.count;
    }
    return self;
}
-(void)generateIdealSlotsArray
{
    //TODO: test this with edge cases
    double totalSlotsRequired = self.requiredPersonsPerInterval*self.numIntervals;
    double idealSlotsPerAvailablePerson = totalSlotsRequired/self.numPeople;
    double numPeopleLeft = self.numPeople;
    double numSlotsLeft = totalSlotsRequired;
    BOOL changed = true;
    while(changed==true){
        changed = false;
        for(int p = 0; p<self.numPeople;p++){
            
            if([self.idealSlotsArray[p] isEqual:@-1] && [self.availPeopleSums[p] intValue] <= idealSlotsPerAvailablePerson ){
                
                self.idealSlotsArray[p]=self.availPeopleSums[p];
                numPeopleLeft--;
                numSlotsLeft-=[self.idealSlotsArray[p] intValue];
                changed = true;
                
            }
            
        }
        if(numPeopleLeft>0){
            idealSlotsPerAvailablePerson = numSlotsLeft/(numPeopleLeft);
        }
    }
    [self calculateUpdatedIdealSlotsPerPerson:idealSlotsPerAvailablePerson];
    
}
 */
@end
