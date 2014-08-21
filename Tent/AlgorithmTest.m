//
//  AlgorithmTest.m
//  Tent
//
//  Created by Jeremy on 8/18/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "AlgorithmTest.h"

static const int kES = 1;
static const NSUInteger kTotalSwapAttemptsAllowed = 5;
//static const NSUInteger kMinimumConsecutiveIntervals = 2;

@interface AlgorithmTest()

    // Basic parameters
    @property (nonatomic) NSUInteger requiredPersonsPerInterval;


    // Ideal Slots
    @property (nonatomic) NSMutableArray *idealSlotsArray; //double or float array

    // Sums Arrays (int[])
    @property (nonatomic) NSMutableArray *availIntervalSums;
    @property (nonatomic) NSMutableArray *assignIntervalSums;
    @property (nonatomic) NSMutableArray *availPeopleSums;
    @property (nonatomic) NSMutableArray *assignPeopleSums;

    // Swap
    @property (nonatomic) NSUInteger swapCountForCurrentPersonAttempt;

@end


@implementation AlgorithmTest

#pragma  mark - Properties
-(NSUInteger)numPeople
{
    return 12;
}
-(NSUInteger)numIntervals
{
    return 100;
}

-(NSMutableArray *)availIntervalSums //ith element is number of people available in interval i
{
    if(!_availIntervalSums) _availIntervalSums = [[NSMutableArray alloc]initWithCapacity:self.numIntervals];
    return _availIntervalSums;
}

-(NSMutableArray *)availPeopleSums //pth element is number of intervals that person p is available
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
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for(int i = 0; i<self.numPeople;i++){
            array[i]=@0;
        }
        _idealSlotsArray = [[NSMutableArray alloc]initWithArray:array];
        
    }
    return _idealSlotsArray;
}

-(NSMutableArray *) availabilitiesSchedule
{
    if(!_availabilitiesSchedule)_availabilitiesSchedule = [[NSMutableArray alloc]init];
    return _availabilitiesSchedule;
}
-(NSMutableArray *) assignmentsSchedule
{
    if(!_assignmentsSchedule) _assignmentsSchedule = [[NSMutableArray alloc]init];
    return _assignmentsSchedule;
}

-(NSArray *)testAvailabilitiesSchedule
{
    return [self generateRandomAvailabilitiesSchedule];
    /*return @[@[@1, @1, @1, @1, @0, @0, @0, @0, @0, @0],
             @[@0, @1, @1, @1, @1, @0, @0, @0, @0, @0],
             @[@0, @0, @1, @1, @1, @1, @0, @0, @0, @0],
             @[@0, @0, @0, @1, @1, @1, @1, @0, @0, @0],
             @[@0, @0, @0, @0, @1, @1, @1, @1, @0, @0],
             @[@0, @0, @0, @0, @0, @1, @1, @1, @1, @0],
             @[@1, @1, @0, @0, @0, @0, @1, @1, @1, @1],
             @[@0, @0, @0, @0, @0, @0, @1, @1, @1, @1],
             @[@0, @0, @0, @0, @1, @1, @0, @0, @1, @1],
             @[@0, @0, @1, @1, @0, @0, @0, @1, @0, @1],
             @[@1, @1, @0, @0, @0, @0, @0, @0, @1, @1],
             @[@1, @1, @1, @1, @0, @0, @0, @1, @1, @0]];*/
}

-(NSArray *)generateRandomAvailabilitiesSchedule
{
    int maxConsec = 5;
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
    NSMutableArray *numConsec = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
    for(int p = 0; p<self.numPeople;p++){
        NSMutableArray *intervals = [[NSMutableArray alloc]initWithCapacity:self.numIntervals];
        [array addObject:intervals];
        [numConsec addObject:@0];
    }
    
    
    for(int i = 0; i<self.numIntervals;i++){
        for(int p = 0; p<self.numPeople;p++){
            if(i>0 && [array[p][i-1] integerValue]==1 && [numConsec[p] integerValue]<maxConsec ){
                array[p][i]=@1;
                numConsec[p] = [NSNumber numberWithInteger:[numConsec[p] integerValue]+1];
            }
            else{
                int x = arc4random() %2;
                array[p][i] = [NSNumber numberWithInteger:x];
                if(x==1){
                    numConsec[p] = [NSNumber numberWithInteger:([numConsec[p] integerValue]+1)];
                }
                else{
                    numConsec[p] = @0;
                }
            }
        }
    }
    
    return (NSArray *)array;
}
-(NSMutableArray *)testAssignmentsSchedule
{
    NSMutableArray *assignments = [[NSMutableArray alloc]initWithCapacity:[self.availabilitiesSchedule count]];
    for(int p = 0; p<[self.availabilitiesSchedule count];p++){
        NSMutableArray *intervals = [[NSMutableArray alloc]initWithCapacity:[self.availabilitiesSchedule[0] count]];
        [assignments addObject:intervals];
        for(int i = 0; i<[self.availabilitiesSchedule[0] count]; i++){
            assignments[p][i]=@0;
        }
    }
    return assignments;
}

#pragma mark - Setup
-(void)setup
{
    
    // Create availabilities Schedule and zero assignment schedule
    self.availabilitiesSchedule = (NSMutableArray *)[self testAvailabilitiesSchedule];
    self.assignmentsSchedule = [self testAssignmentsSchedule];
    
    //NSLog(@"Availablitities: %@", self.availabilitiesSchedule);
    //NSLog(@"Assignments: %@", self.assignmentsSchedule);
    
    
    // PPI
    self.requiredPersonsPerInterval = ceil(self.numPeople/3.0);
    //NSLog(@"PPI %d", self.requiredPersonsPerInterval);
    
    
    // Sums Arrays
    [self calculateAvailIntervalSums];
    [self calculateAvailPeopleSums];
    //NSLog(@"AvailIntervalSums: %@ AvailPeopleSums: %@", self.availIntervalSums, self.availPeopleSums);
    
    // Check Error
    if([self checkForError]) return;
    
    // Ideal Slots arrays
    [self generateIdealSlotsArray];
    
    // Generate Schedule
    [self generateSchedule];
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
            NSLog(@"Person %d's total # of intervals available: %@", p, self.availPeopleSums[p]);
            
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

#pragma mark - Sums

-(void) calculateAvailPeopleSums
{
    
    for(int r = 0;r<[self.availabilitiesSchedule count];r++){
        NSUInteger sum = [self sumColumnsForRow:r ofSchedule:self.availabilitiesSchedule];
        self.availPeopleSums[r] = [NSNumber numberWithInteger:sum];
    }
    
}
-(void) calculateAssignPeopleSums
{
    
    for(int r = 0;r<[self.assignmentsSchedule count];r++){
        NSUInteger sum = [self sumColumnsForRow:r ofSchedule:self.assignmentsSchedule];
        self.assignPeopleSums[r] = [NSNumber numberWithInteger:sum];
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
-(void) calculateAvailIntervalSums
{
    
    
    for(int c = 0; c<[self.availabilitiesSchedule[0] count];c++){
        NSUInteger sum = [self sumRowsForColumn:c ofSchedule:self.availabilitiesSchedule];
        self.availIntervalSums[c] = [NSNumber numberWithInteger:sum];
    }
    
    
}
-(void) calculateAssignIntervalSums
{
    
    
    for(int c = 0; c<[self.assignmentsSchedule[0] count];c++){
        NSUInteger sum = [self sumRowsForColumn:c ofSchedule:self.assignmentsSchedule];
        self.assignIntervalSums[c] = [NSNumber numberWithInteger:sum];
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

#pragma mark - Generate Schedule
-(void)generateSchedule
{
    //NSLog(@"numPeople: %lu numIntervals: %lu", (unsigned long)self.numPeople, (unsigned long)self.numIntervals);
    
    //NSLog(@"Assignments Schedule: %@", self.assignmentsSchedule);
    
    // Initial Assignments
        [self assignIntervals];
        NSLog(@"Assignments Schedule: %@", self.assignmentsSchedule);
        [self printAssignmentScheduleIntervalView];
    // Calculate Assignment Sums
    
        [self calculateAssignPeopleSums];
        [self calculateAssignIntervalSums];
    
        // print both sums
    
            NSLog(@"AvailIntervalSums: %@ AvailPeopleSums: %@", self.availIntervalSums, self.availPeopleSums);
            NSLog(@"AssignIntervalSums: %@ AssignPeopleSums: %@", self.assignIntervalSums, self.assignPeopleSums);
    // Swap
        [self swapIntervalsUntilEqualityIsSufficient];
    
    // Re-calculate Assignment Sums
        [self calculateAssignPeopleSums];
        [self calculateAssignIntervalSums];
        //print
    
        NSLog(@"Assignments Schedule: %@", self.assignmentsSchedule);
     NSLog(@"AssignIntervalSums: %@ AssignPeopleSums: %@", self.assignIntervalSums, self.assignPeopleSums);
    //[self swapSolos];
    
     //Calculate Assignment Sums
    
}

-(void)assignIntervals
{
    int assignCountInThisInterval;
    //sort availPeopleSums
    for(int i = 0; i<self.numIntervals;i++){
        assignCountInThisInterval = 0;
        
        /*//if min number available, assign slots to each person available
        if([self.availIntervalSums[i] intValue]==self.requiredPersonsPerInterval){
            for(int p = 0; p<self.numPeople; p++){
                if([self.availabilitiesSchedule[p][i] isEqual:@1]){
                    self.assignmentsSchedule[p][i]=@1;
                }
            }
        }*/
        
        
        //for now, just assign intervals to first people available
        for(int p = 0; p<self.numPeople;p++){
            if([self.availabilitiesSchedule[p][i] isEqual:@1]){
                self.assignmentsSchedule[p][i]=@1;
                assignCountInThisInterval++;
            }
            if(assignCountInThisInterval==self.requiredPersonsPerInterval) break;
            
        }
    }
}

-(void)swapSingleInterval:(NSUInteger)i assignToPerson:(NSUInteger)personGainingInterval takeAwayFromPerson:(NSUInteger)personLosingInterval
{
    self.assignmentsSchedule[personGainingInterval][i]=@1;
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

-(void)swapFromBeginningIfPossibleAssignIntervalTo:(NSUInteger)personGainingInterval takeAwayFrom:(NSUInteger)personLosingInterval
{
    for(int i = 0;i<self.numIntervals-1;i++){
        //maybe change condition to be less than floor int value of ideal slots array
        if(([self.assignPeopleSums[personGainingInterval] integerValue]>=[self.idealSlotsArray[personGainingInterval] floatValue]) || ([self.assignPeopleSums[personLosingInterval] integerValue] <= [self.idealSlotsArray[personLosingInterval] floatValue])){
            return;
        }
        
        
        //if person1 is free but not assigned to this interval && person2 is assigned to this interval
        if([self.availabilitiesSchedule[personGainingInterval][i] integerValue]==1 && [self.assignmentsSchedule[personGainingInterval][i] integerValue]==0 && [self.assignmentsSchedule[personLosingInterval][i] integerValue] ==1){
            
            //if person2 is not assigned to the previous interval or it's the first interval
            if(i == 0 || [self.assignmentsSchedule[personLosingInterval][i-1] integerValue] ==0){
                
                //switch intervals
                [self swapSingleInterval:i assignToPerson:personGainingInterval takeAwayFromPerson:personLosingInterval];
            }
        }
       
        
    }
    
}
-(void)swapFromEndIfPossibleAssignIntervalTo:(NSUInteger)personGainingInterval takeAwayFrom:(NSUInteger)personLosingInterval
{
    //change to allow ends to be swapped
    for(int i = self.numIntervals-1; i>0;i--){
        if([self.assignPeopleSums[personGainingInterval] integerValue] >= [self.idealSlotsArray[personGainingInterval ] floatValue] || [self.assignPeopleSums[personLosingInterval] integerValue] <= [self.idealSlotsArray[personLosingInterval] floatValue]){
            return;
        }
        
        //if person1 is free but not assigned to this interval && person2 is assigned to this interval
        if([self.availabilitiesSchedule[personGainingInterval][i] integerValue]==1 && [self.assignmentsSchedule[personGainingInterval][i] integerValue]==0 && [self.assignmentsSchedule[personLosingInterval][i] integerValue] ==1){
            
            //if person2 is not assigned to the previous (chronologically, next) interval or it's the last interval
            if((i == self.numIntervals-1) || [self.assignmentsSchedule[personLosingInterval][i+1] integerValue] ==0){
            
                //switch intervals
                [self swapSingleInterval:i assignToPerson:personGainingInterval takeAwayFromPerson:personLosingInterval];
            }
        }
    }
    
}
-(void)swapFromBeginningIfPossiblePreservingMinConsecAssignIntervalTo:(NSUInteger)personGainingInterval takeAwayFrom:(NSUInteger)personLosingInterval
{
    
}
-(void)swapFromEndIfPossiblePreservingMinConsecAssignIntervalTo:(NSUInteger)personGainingInterval takeAwayFrom:(NSUInteger)personLosingInterval
{
    
}




-(void)swapSolos
{
    
}


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
    
    
    for(int p = 0; p<[self.assignmentsSchedule count]; p++){
        for(int i = 0; i<[self.assignmentsSchedule[0] count];i++){
            assignmentScheduleIntervalView[i][p] = self.assignmentsSchedule[p][i];
        }
    }
    
    NSLog(@"AssignmentsScheduleIntervalView: %@", assignmentScheduleIntervalView);
}


@end
