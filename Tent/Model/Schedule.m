//
//  Schedule.m
//  Tent
//
//  Created by Shrek on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Schedule.h"


@interface Schedule()

// Basic parameters
    @property (nonatomic) NSUInteger requiredPersonsPerInterval;


// Ideal Slots
    @property (nonatomic) NSMutableArray *idealSlotsArray; //double or gfloat array

// Sums Arrays (int[])
    @property (nonatomic) NSMutableArray *availIntervalSums;
    @property (nonatomic) NSMutableArray *assignIntervalSums;
    @property (nonatomic) NSMutableArray *availPeopleSums;
    @property (nonatomic) NSMutableArray *assignPeopleSums;

// Matrix Schedules (int[])
    //@property (nonatomic, weak) NSMutableArray *availabilitiesSchedule;
    //@property (nonatomic) NSMutableArray *assignmentsSchedule;


@end

@implementation Schedule

+(NSUInteger)testNumPeople
{
    return 12;
}
+(NSUInteger)testNumIntervals
{
    return 10;
}

-(NSMutableArray *)availIntervalSums
{
    if(!_availIntervalSums) _availIntervalSums = [[NSMutableArray alloc]initWithCapacity:self.numIntervals];
    return _availIntervalSums;
}

-(NSMutableArray *)availPeopleSums
{
    if(!_availPeopleSums) _availPeopleSums = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
    return _availPeopleSums;
}

-(NSMutableArray *)idealSlotsArray
{
    if(!_idealSlotsArray){
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for(int i = 0; i<self.numPeople;i++){
            array[i]=@0;
        }
        _idealSlotsArray = [[NSMutableArray alloc]initWithArray:array];

    }
    return _idealSlotsArray;
}


-(NSMutableArray *) assignmentsSchedule
{
    if(!_assignmentsSchedule){
        _assignmentsSchedule = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
        for(int p = 0; p<self.numPeople;p++){
            NSMutableArray *peopleAssignInterval = [[NSMutableArray alloc]initWithCapacity:self.numIntervals];
            for(int i = 0; i <self.numIntervals;i++){
                [peopleAssignInterval addObject:@0];
            }
            [_assignmentsSchedule addObject:peopleAssignInterval];
        }
    }
    return _assignmentsSchedule;
}
#pragma mark - init

-(instancetype)initWithNumPeople:(NSUInteger)numPeople withNumIntervals:(NSUInteger)numIntervals
{
    self = [super init];
    if(self){
        self.numPeople = numPeople;
        self.numIntervals = numIntervals;
    }
    return self;
}


-(instancetype)initWithAvailabilitiesSchedule:(NSMutableArray *)availSchedule
{
    self = [super init];
    if(self){
        self.availabilitiesSchedule = availSchedule;
        self.numPeople = [availSchedule count];
        self.numIntervals = [availSchedule[0] count];
    }
    return self;
}

-(void)setup
{
    
    // PPI
        self.requiredPersonsPerInterval = ceil(self.numPeople/3.0);
        //NSLog(@"PPI %d", self.requiredPersonsPerInterval);
    
    
    // Sums Arrays
        [self calculateAvailIntervalSumsOfSchedule:self.availabilitiesSchedule];
        [self calculateAvailPeopleSumsOfSchedule:self.availabilitiesSchedule];
        NSLog(@"Interval: %@ People: %@", self.availIntervalSums, self.availPeopleSums);

    // Check Error
        if([self checkForError]) return;
    
    // Ideal Slots arrays
        [self generateIdealSlotsArray];
    
    // Generate Schedule
        [self generateSchedule];
}


#pragma mark - Setup methods

-(BOOL)checkForError
{
    BOOL error = false;
    for(int c = 0; c<self.numIntervals;c++){
        int sum = [self.availIntervalSums[c] intValue];
        if(sum<self.requiredPersonsPerInterval){
            NSLog(@"Not enough people in interval %d", c);
            error = true;
        }
        
    }
    return error;
}
-(void)generateIdealSlotsArray
{
    double totalSlotsRequired = self.requiredPersonsPerInterval*self.numIntervals;
    double idealSlotsPerAvailablePerson = totalSlotsRequired/self.numPeople;
    double numPeopleLeft = self.numPeople;
    double numSlotsLeft = totalSlotsRequired;
    BOOL changed = true;
    while(changed==true){
        changed = false;
        for(int i = 0; i<self.numPeople;i++){
            NSLog(@"idealSlotsArrayAtIndex %@", self.availPeopleSums[i]);

            if([self.availPeopleSums[i] intValue] < idealSlotsPerAvailablePerson && [self.idealSlotsArray[i] isEqual:@0] ){
                
                //[self.idealSlotsArray removeObjectAtIndex:i];
                //[self.idealSlotsArray insertObject:self.availPeopleSums[i] atIndex:i];
                self.idealSlotsArray[i]=self.availPeopleSums[i];
                numPeopleLeft--;
                numSlotsLeft-=[self.idealSlotsArray[i] intValue];
                changed = true;
                
            }
            
        }
        if(numPeopleLeft>0){
            idealSlotsPerAvailablePerson = numSlotsLeft/(numPeopleLeft);
        }
    }
    [self calculateUpdatedIdealSlotsPerPerson:idealSlotsPerAvailablePerson];
    NSLog(@"idealSlotsArray %@", self.idealSlotsArray);
}
-(void)calculateUpdatedIdealSlotsPerPerson:(double)idealSlotsPerAvailablePerson
{
    for(int i = 0; i<self.numPeople;i++) {
        if([self.idealSlotsArray[i] isEqual:@0]){
            self.idealSlotsArray[i]=[NSNumber numberWithDouble:idealSlotsPerAvailablePerson];
        }
    }
}

#pragma mark - Generate Schedule
-(void)generateSchedule
{
    NSLog(@"numPeople: %d numIntervals: %d", self.numPeople, self.numIntervals);
    
    NSLog(@"Assignments Schedule: %@", self.assignmentsSchedule);

    [self assignIntervals];
    NSLog(@"Assignments Schedule: %@", self.assignmentsSchedule);
    //[self swapAll];
    //[self swapSolos];
    
}

-(void)assignIntervals
{
   //sort availPeopleSums
    for(int i = 0; i<self.numIntervals;i++){
       
        //if min number available, assign slots to each person available
        if([self.availIntervalSums[i] intValue]==self.requiredPersonsPerInterval){
            
            for(int p = 0; p<self.numPeople; p++){
                if([self.availabilitiesSchedule[p][i] isEqual:@1]){
                    self.assignmentsSchedule[p][i]=@1;
                }
                /*NSMutableArray *pAvailableIntervalsArray = self.availabilitiesSchedule[p];
                for(int pintv = 0; pintv<self.numIntervals;pintv++){
                    if([pAvailableIntervalsArray[pintv] intValue]==1){
                        //NSLog(@"Test");
                        
                        self.assignmentsSchedule[p][i]=@1;
                    }
                }*/
            }
        }
    }
}

-(void)swapAll
{
    
}

-(void)swapSolos
{
    
}


#pragma mark - Sums

-(void) calculateAvailPeopleSumsOfSchedule: (NSMutableArray *)schedule
{
    
    for(int r = 0;r<[schedule count];r++){
        NSUInteger sum = [self sumColumnsForRow:r ofSchedule:self.availabilitiesSchedule];
        self.availPeopleSums[r] = [NSNumber numberWithInteger:sum];
    }
    
}
-(NSUInteger) sumColumnsForRow:(int)r ofSchedule:(NSMutableArray *)schedule
{
    int sum=0;
    NSMutableArray* personArray = [schedule objectAtIndex:r];
    for(int c = 0; c<[schedule[0] count];c++){
        sum+=[[personArray objectAtIndex:c]intValue];
    }
    return sum;
    
}
-(void) calculateAvailIntervalSumsOfSchedule: (NSMutableArray *)schedule
{
    
    
    for(int c = 0; c<[schedule[0] count];c++){
        NSUInteger sum = [self sumRowsForColumn:c ofSchedule:self.availabilitiesSchedule];
        self.availIntervalSums[c] = [NSNumber numberWithInteger:sum];
    }
    
    
}
-(int) sumRowsForColumn:(int)c ofSchedule:(NSMutableArray *)schedule
{
    
    int sum=0;
    for(int r = 0; r<[schedule count];r++){
        NSMutableArray* personArray = [schedule objectAtIndex:r];
        sum+=[[personArray objectAtIndex:c]intValue];
    }
    return sum;
    
}


@end
