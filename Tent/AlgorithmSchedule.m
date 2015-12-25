//
//  AlgorithmSchedule.m
//  Tent
//
//  Created by Jeremy on 11/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "AlgorithmSchedule.h"


static const int kES = 1;
static const NSUInteger kTotalSwapAttemptsAllowed = 5;

@interface AlgorithmSchedule ()

// Basic Parameters
@property(nonatomic) NSUInteger numPeople;
@property(nonatomic) NSUInteger numIntervals;
@property (nonatomic) NSUInteger requiredPersonsPerInterval;
@property (nonatomic) NSUInteger intervalLengthInMinutes;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@property (nonatomic) NSMutableArray *assignmentsSchedule;


// Ideal Slots
@property (nonatomic) NSMutableArray *idealSlotsArray; //double or gfloat array

// Sums Arrays (int[])
@property (nonatomic) NSMutableArray *availIntervalSums;
@property (nonatomic) NSMutableArray *assignIntervalSums;
@property (nonatomic) NSMutableArray *availPeopleSums;
@property (nonatomic) NSMutableArray *assignPeopleSums;

// Swap
@property (nonatomic) NSUInteger swapCountForCurrentPersonAttempt;


@end

@implementation AlgorithmSchedule

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

-(NSMutableArray *)assignIntervalSums //ith element is number of people assigned in interval i
{
    if(!_assignIntervalSums)_assignIntervalSums = [[NSMutableArray alloc]initWithCapacity:self.numIntervals];
    return _assignIntervalSums;
}
-(NSMutableArray *)assignPeopleSums //pth element is number of intervals that person p is assigned
{
    if(!_assignPeopleSums)_assignPeopleSums = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
    return _assignPeopleSums;
}

-(NSMutableArray *)idealSlotsArray
{
    if(!_idealSlotsArray){
        NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
        for(int i = 0; i<self.numPeople;i++){
            [array addObject:@0];
        }
        _idealSlotsArray = [[NSMutableArray alloc]initWithArray:array];
        
    }
    return _idealSlotsArray;
}


-(NSMutableArray *) assignmentsSchedule
{
    if(!_assignmentsSchedule) _assignmentsSchedule = [[NSMutableArray alloc]init];
    return _assignmentsSchedule;
}


#pragma mark - Setup methods


-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate intervalLengthInMinutes: (NSUInteger)intervalLength assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numIntervals:(NSUInteger)numIntervals
{
    self = [super init];
    if(self){
        self.startDate = startDate;
        self.endDate = endDate;
        self.intervalLengthInMinutes = intervalLength;
        self.assignmentsSchedule = assignmentsSchedule;
        self.numIntervals = numIntervals;
        self.numPeople = assignmentsSchedule.count;
        self.requiredPersonsPerInterval = ceil(self.numPeople/3.0);
        [self setup];
    }
    return self;
}
-(BOOL)setup
{
    //[self resetAssignments]; //taken care of in availPeopleSums
    
    // Sums Arrays
    [self calculateAvailPeopleSums];
    [self calculateAvailIntervalSums];

    
    // Check Error
    //if([self checkForError]) return false;
    
    
    
    // Generate Schedule
    //[self generateSchedule];
    
    return true;
}



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
        for(int p = 0; p<self.numPeople;p++){
            
            if([self.availPeopleSums[p] intValue] < idealSlotsPerAvailablePerson && [self.idealSlotsArray[p] isEqual:@0] ){
                
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
-(void)calculateUpdatedIdealSlotsPerPerson:(double)idealSlotsPerAvailablePerson
{
    for(int i = 0; i<self.numPeople;i++) {
        if([self.idealSlotsArray[i] isEqual:@0]){
            self.idealSlotsArray[i]=[NSNumber numberWithDouble:idealSlotsPerAvailablePerson];
        }
    }
}

#pragma mark - Generate Schedule
-(NSMutableArray *)generateAssignments
{
    // Ideal Slots arrays
    [self generateIdealSlotsArray];
    
    // Initial Assignments
    [self assignIntervals];
    
    // Calculate Assignment Sums
    [self calculateAssignPeopleSums];
    [self calculateAssignIntervalSums];
    
    // Swap
    [self swapIntervalsUntilEqualityIsSufficient];
    
    
    
    // Re-calculate Assignment Sums
    [self calculateAssignPeopleSums];
    [self calculateAssignIntervalSums];
    
    //[self swapSolos];
    return self.assignmentsSchedule;
    
}

-(void)assignIntervals
{
    int assignCountInThisInterval;
    //sort availPeopleSums
    for(int i = 0; i<self.numIntervals;i++){
        assignCountInThisInterval = 0;
        //for now, just assign intervals to first people available and then swap
        for(int p = 0; p<self.numPeople;p++){
            if([self.assignmentsSchedule[p][i] isEqual:@1]){
                self.assignmentsSchedule[p][i]=@2;
                assignCountInThisInterval++;
            }
            if(assignCountInThisInterval==self.requiredPersonsPerInterval) break;
            
        }
    }
}

-(void)swapSingleInterval:(NSUInteger)i assignToPerson:(NSUInteger)personGainingInterval takeAwayFromPerson:(NSUInteger)personLosingInterval
{
    self.assignmentsSchedule[personGainingInterval][i]=@2;
    self.assignmentsSchedule[personLosingInterval][i]=@0;
    
    self.assignPeopleSums[personGainingInterval] = [NSNumber numberWithInteger:[self.assignPeopleSums[personGainingInterval] integerValue]+1];
    self.assignPeopleSums[personLosingInterval] = [NSNumber numberWithInteger:[self.assignPeopleSums[personLosingInterval] integerValue]-1];
    
    self.swapCountForCurrentPersonAttempt++;
}
-(void)swapIntervalsUntilEqualityIsSufficient
{
    int swapAttemptsCount = 0; //# times looped through everthing and swapped when possible
    while(swapAttemptsCount<kTotalSwapAttemptsAllowed && ([self maximumValueInArray:self.assignPeopleSums] - [self minimumValueInArray:self.assignPeopleSums]) > ([self maximumValueInArray:self.idealSlotsArray] - [self minimumValueInArray:self.idealSlotsArray])){
        for(int p = 0; p<self.numPeople;p++){
            self.swapCountForCurrentPersonAttempt = 1; //maybe change this to a boolean (swapped at least o once or no swap)
            while(self.swapCountForCurrentPersonAttempt > 0  && fabsf([self.idealSlotsArray[p] floatValue] - [self.assignPeopleSums[p] floatValue]) > kES){
                self.swapCountForCurrentPersonAttempt = 0;
                
                [self attemptAllSwapsForPersonAtIndex:p];
            }
            
        }
        swapAttemptsCount++;
    }
}

-(void)attemptAllSwapsForPersonAtIndex:(NSUInteger)person1
{
    for(int person2=0;person2<self.numPeople;person2++){
        if([self.assignPeopleSums[person1] integerValue]<[self.idealSlotsArray[person1]floatValue] && [self.assignPeopleSums[person2] integerValue] >[self.idealSlotsArray[person2] floatValue]){
            [self swapFromBeginningIfPossibleAssignIntervalTo:person1 takeAwayFrom:person2];
            [self swapFromEndIfPossibleAssignIntervalTo:person1 takeAwayFrom:person2];
        }
        else if([self.assignPeopleSums[person1] integerValue]>[self.idealSlotsArray[person1]floatValue] && [self.assignPeopleSums[person2] integerValue] <[self.idealSlotsArray[person2] floatValue]){
            [self swapFromBeginningIfPossibleAssignIntervalTo:person2 takeAwayFrom:person1];
            [self swapFromEndIfPossibleAssignIntervalTo:person2 takeAwayFrom:person1];
        }
    }
}
-(BOOL)personIndex:(NSUInteger)p isAvailableInInterval:(NSUInteger)i
{
    if([self.assignmentsSchedule[p][i] isEqual:@1] || [self.assignmentsSchedule[p][i] isEqual:@2] ){
        return YES;
    }else{
        return NO;
    }
}
-(BOOL)personIndex:(NSUInteger)p isAssignedInInterval:(NSUInteger)i
{
    if([self.assignmentsSchedule[p][i] isEqual:@2] ){
        return YES;
    }else{
        return NO;
    }
}
-(void)swapFromBeginningIfPossibleAssignIntervalTo:(NSUInteger)personGainingInterval takeAwayFrom:(NSUInteger)personLosingInterval
{
    for(int i = 0;i<self.numIntervals-1;i++){
        //changed condition to be less than ceil/floor int value of ideal slots array
        if(([self.assignPeopleSums[personGainingInterval] integerValue]>=ceil([self.idealSlotsArray[personGainingInterval] floatValue])) || ([self.assignPeopleSums[personLosingInterval] integerValue] <= ceil([self.idealSlotsArray[personLosingInterval] floatValue]))){
            return;
        }
        
        
        //if person1 is free but not assigned to this interval && person2 is assigned to this interval
        if([self personIndex:personGainingInterval isAvailableInInterval:i] && ![self personIndex:personGainingInterval isAssignedInInterval:i] && [self personIndex:personLosingInterval isAssignedInInterval:i]){
            
            //if person2 is not assigned to the previous interval or it's the first interval
            if(i == 0 || ![self personIndex:personLosingInterval isAssignedInInterval:i-1]){
                
                //switch intervals
                [self swapSingleInterval:i assignToPerson:personGainingInterval takeAwayFromPerson:personLosingInterval];
            }
        }
        
        
    }
    
}
-(void)swapFromEndIfPossibleAssignIntervalTo:(NSUInteger)personGainingInterval takeAwayFrom:(NSUInteger)personLosingInterval
{
    //change to allow ends to be swapped
    for(NSUInteger i = self.numIntervals-1; i>0;i--){
        if([self.assignPeopleSums[personGainingInterval] integerValue] >= ceil([self.idealSlotsArray[personGainingInterval ] floatValue]) || [self.assignPeopleSums[personLosingInterval] integerValue] <= ceil([self.idealSlotsArray[personLosingInterval] floatValue])){
            return;
        }
        
        //if person1 is free but not assigned to this interval && person2 is assigned to this interval
       if([self personIndex:personGainingInterval isAvailableInInterval:i] && ![self personIndex:personGainingInterval isAssignedInInterval:i] && [self personIndex:personLosingInterval isAssignedInInterval:i]){
            
            //if person2 is not assigned to the previous (chronologically, next) interval or it's the last interval
            if((i == self.numIntervals-1) || ![self personIndex:personLosingInterval isAssignedInInterval:i+1]){
                
                //switch intervals
                [self swapSingleInterval:i assignToPerson:personGainingInterval takeAwayFromPerson:personLosingInterval];
            }
        }
    }
    
}


#pragma mark - Array Stuff
-(float)maximumValueInArray:(NSArray *)array
{
    float maxValue = [array[0] floatValue];
    for(int i = 0; i<[array count]; i++){
        float currentValue = [array[i] floatValue];
        if(currentValue > maxValue) maxValue = currentValue;
    }
    
    return maxValue;
}

-(float)minimumValueInArray:(NSArray *)array
{
    float minValue = [array[0] floatValue];
    for(int i = 0; i<[array count]; i++){
        float currentValue = [array[i] floatValue];
        if(currentValue <minValue) minValue = currentValue;
    }
    return minValue;
}

-(void)printAssignmentScheduleIntervalView
{
    NSMutableArray *assignmentScheduleIntervalView = [[NSMutableArray alloc]initWithCapacity:self.numIntervals];
    for(int i = 0; i<self.numIntervals;i++){
        NSMutableArray *peopleAssignedToThisInterval = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
        [assignmentScheduleIntervalView addObject:peopleAssignedToThisInterval];
    }
    
    
    for(int p = 0; p<self.numPeople; p++){
        for(int i = 0; i<self.numIntervals;i++){
            assignmentScheduleIntervalView[i][p] = self.assignmentsSchedule[p][i];
        }
    }
    
    NSLog(@"AssignmentsScheduleIntervalView: %@", assignmentScheduleIntervalView);
}




#pragma mark - Sums

-(void)calculateAvailAndAssignPeopleSums
{
    for(int r = 0;r<self.numPeople;r++){
        int assignSums = 0;
        int availSums = 0;
        for(int c = 0; c<self.numIntervals;c++){
            if([self.assignmentsSchedule[r][c] integerValue]== 2){
                assignSums += 1;
                availSums += 1;
            }else if ([self.assignmentsSchedule[r][c] integerValue]== 1){
                availSums += 1;
            }
        }
        self.availPeopleSums[r] = [NSNumber numberWithInteger:availSums];
        self.assignPeopleSums[r] = [NSNumber numberWithInteger:assignSums];
        
    }
}
-(void)calculateAvailPeopleSums
{
    for(int r = 0;r<self.numPeople;r++){
        int availSums = 0;
        for(int c = 0; c<self.numIntervals;c++){
            if ([self.assignmentsSchedule[r][c] integerValue]== 1 || [self.assignmentsSchedule[r][c] integerValue]== 2){
                availSums += 1;
                self.assignmentsSchedule[r][c] = @1; //takes care of resetting assignments schedule. maybe move to new method (this would make it clearer, but also less efficient)
            }
        }
        self.availPeopleSums[r] = [NSNumber numberWithInteger:availSums];
        
    }
}
-(void)calculateAssignPeopleSums
{
    for(int r = 0;r<self.numPeople;r++){
        int assignSums = 0;
        for(int c = 0; c<self.numIntervals;c++){
            if([self.assignmentsSchedule[r][c] integerValue] == 2){
                assignSums += 1;
            }
        }
        self.assignPeopleSums[r] = [NSNumber numberWithInteger:assignSums];

    }

}

-(void)calculateAvailAndAssignIntervalSums
{
    for(int c = 0; c<self.numIntervals; c++){
        int assignSums = 0;
        int availSums = 0;
        for(int r = 0; r<self.numPeople; r++){
            if([self.assignmentsSchedule[r][c] integerValue] == 2){
                assignSums += 1;
                availSums += 1;
            }else if([self.assignmentsSchedule[r][c] integerValue] == 1){
                availSums += 1;
            }

        }
        self.assignIntervalSums[c] = [NSNumber numberWithInteger:assignSums];
        self.availIntervalSums[c] = [NSNumber numberWithInteger:availSums];

    }
}
-(void)calculateAvailIntervalSums
{
    for(int c = 0; c<self.numIntervals; c++){
        int availSums = 0;
        for(int r = 0; r<self.numPeople; r++){
            if([self.assignmentsSchedule[r][c] integerValue] == 1 || [self.assignmentsSchedule[r][c] integerValue] == 2){
                availSums += 1;
            }
            
        }
        self.availIntervalSums[c] = [NSNumber numberWithInteger:availSums];
        
    }

}
-(void)calculateAssignIntervalSums
{
    for(int c = 0; c<self.numIntervals; c++){
        int assignSums = 0;
        for(int r = 0; r<self.numPeople; r++){
            if([self.assignmentsSchedule[r][c] integerValue] == 2){
                assignSums += 1;
            }
        }
        self.assignIntervalSums[c] = [NSNumber numberWithInteger:assignSums];
        
    }

}
/*
-(void) calculateAvailPeopleSums
{
    
    for(int r = 0;r<self.numPeople;r++){
        NSUInteger sum = [self sumColumnsForRow:r ofSchedule:self.availabilitiesSchedule];
        self.availPeopleSums[r] = [NSNumber numberWithInteger:sum];
    }
    
}
-(void) calculateAssignPeopleSums
{
    
    for(int r = 0;r<self.numPeople;r++){
        NSUInteger sum = [self sumColumnsForRow:r ofSchedule:self.assignmentsSchedule];
        self.assignPeopleSums[r] = [NSNumber numberWithInteger:sum];
    }
    
}

-(NSUInteger) sumColumnsForRow:(int)r ofSchedule:(NSMutableArray *)schedule
{
    int sum=0;
    NSMutableArray* personArray = [schedule objectAtIndex:r];
    for(int c = 0; c<self.numIntervals;c++){
        sum+=[[personArray objectAtIndex:c]intValue];
    }
    return sum;
    
}
-(void) calculateAvailIntervalSums
{
    
    
    for(int c = 0; c<self.numIntervals;c++){
        NSUInteger sum = [self sumRowsForColumn:c ofSchedule:self.availabilitiesSchedule];
        self.availIntervalSums[c] = [NSNumber numberWithInteger:sum];
    }
    
    
}
-(void) calculateAssignIntervalSums
{
    
    
    for(int c = 0; c<self.numIntervals;c++){
        NSUInteger sum = [self sumRowsForColumn:c ofSchedule:self.assignmentsSchedule];
        self.assignIntervalSums[c] = [NSNumber numberWithInteger:sum];
    }
    
    
}
-(int) sumRowsForColumn:(int)c ofSchedule:(NSMutableArray *)schedule
{
    
    int sum=0;
    for(int r = 0; r<self.numPeople;r++){
        NSMutableArray* personArray = [schedule objectAtIndex:r];
        sum+=[[personArray objectAtIndex:c]intValue];
    }
    return sum;
    
}

*/

@end
