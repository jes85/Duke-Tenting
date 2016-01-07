//
//  AlgorithmSchedule.m
//  Tent
//
//  Created by Jeremy on 11/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "AlgorithmScheduleOld2.h"
#import "Interval.h"
#import "Person.h"
#import "AlgorithmInterval.h"
#import "AlgorithmPerson.h"

static const int kES = 1;
static const NSUInteger kTotalSwapAttemptsAllowed = 5;

@interface AlgorithmScheduleOld2 ()








// Basic Parameters
@property( nonatomic) NSUInteger numPeople;
@property (nonatomic) NSUInteger numTotalIntervals;
@property (nonatomic) NSUInteger requiredPersonsPerInterval;
@property (nonatomic) NSUInteger normalIntervalLengthInMinutes;

@property (nonatomic) NSMutableArray *intervalDataByOverallRow;
@property (nonatomic) NSMutableArray *personsArray;

@property (nonatomic) NSMutableArray *nightIntervalsArray;
@property (nonatomic) NSMutableArray *arrayOfDayIntervalsArrays;
@property (nonatomic) NSUInteger numDayIntervals;



// Ideal Slots
@property (nonatomic) NSMutableArray *idealSlotsArrayNight;
@property (nonatomic) NSMutableArray *idealSlotsArrayDay;

// Sums Arrays (int[])
@property (nonatomic) NSMutableArray *numNightIntervalsEachPersonIsAvailable;
@property (nonatomic) NSMutableArray *numNightIntervalsEachPersonIsAssigned;
@property (nonatomic) NSMutableArray *numDayIntervalsEachPersonIsAvailable;
@property (nonatomic) NSMutableArray *numDayIntervalsEachPersonIsAssigned;


// Swap
@property (nonatomic) NSUInteger swapCountForCurrentPersonAttempt;


@end

@implementation AlgorithmScheduleOld2


-(NSMutableArray *)arrayOfDayIntervalsArrays
{
    if(!_arrayOfDayIntervalsArrays) _arrayOfDayIntervalsArrays = [[NSMutableArray alloc]init];
    return _arrayOfDayIntervalsArrays;
}

-(NSMutableArray *)nightIntervalsArray
{
    if(!_nightIntervalsArray) _nightIntervalsArray = [[NSMutableArray alloc]init];
    return _nightIntervalsArray;
}

-(NSMutableArray *)numNightIntervalsEachPersonIsAvailable
{
    if(!_numNightIntervalsEachPersonIsAvailable) _numNightIntervalsEachPersonIsAvailable = [[NSMutableArray alloc]init];
    return _numNightIntervalsEachPersonIsAvailable;
}
-(NSMutableArray *)numNightIntervalsEachPersonIsAssigned
{
    if(!_numNightIntervalsEachPersonIsAssigned) _numNightIntervalsEachPersonIsAssigned = [[NSMutableArray alloc]init];
    return _numNightIntervalsEachPersonIsAssigned;
}

-(NSMutableArray *)numDayIntervalsEachPersonIsAvailable
{
    if(!_numDayIntervalsEachPersonIsAvailable) _numDayIntervalsEachPersonIsAvailable = [[NSMutableArray alloc]init];
    return _numDayIntervalsEachPersonIsAvailable;
}

-(NSMutableArray *)numDayIntervalsEachPersonIsAssigned
{
    if(!_numDayIntervalsEachPersonIsAssigned) _numDayIntervalsEachPersonIsAssigned = [[NSMutableArray alloc]init];
    return _numDayIntervalsEachPersonIsAssigned;
}


#pragma mark - Setup methods


-(instancetype)initWithSchedule:(Schedule *)schedule
{
    self = [super init];
    if(self){
        //self.intervalDataByOverallRow = [[NSMutableArray alloc]initWithArray:schedule.intervalDataByOverallRow copyItems:YES];
        //self.personsArray = [[NSMutableArray alloc]initWithArray:schedule.personsArray copyItems:YES];
        self.intervalDataByOverallRow = [self createAlgorithmIntervalDataByOverallRowFromArray:schedule.intervalDataByOverallRow];
        self.personsArray = [self createAlgorithmPersonsArrayFromArray:schedule.personsArray];
        self.numTotalIntervals = schedule.intervalDataByOverallRow.count;
        self.numPeople = schedule.personsArray.count;
        self.requiredPersonsPerInterval = ceil(self.numPeople / 3.0);
        [self setup];
    }
    return self;
}

-(NSMutableArray *)createAlgorithmIntervalDataByOverallRowFromArray:(NSMutableArray *)intervalDataByOverallRow
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:intervalDataByOverallRow.count];
    for(int i = 0; i<intervalDataByOverallRow.count;i++){
        Interval *interval = intervalDataByOverallRow[i];
        AlgorithmInterval *algInterval = [[AlgorithmInterval alloc]initWithInterval:interval overallIndex:i];
        [array addObject:algInterval];
    }
    return array;
}

-(NSMutableArray *)createAlgorithmPersonsArrayFromArray:(NSMutableArray *)personsArray
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:personsArray.count];
    for(int i = 0; i<personsArray.count;i++){
        Person *person = personsArray[i];
        AlgorithmPerson *algPerson = [[AlgorithmPerson alloc]initWithPerson:person scheduleIndex:i];
        [array addObject:algPerson];
    }
    return array;
}

//for testing
-(void)convertAllIntervalsToNight:(BOOL)night
{
    for(AlgorithmInterval *interval in self.intervalDataByOverallRow){
        interval.night = night;
    }
}

-(BOOL)setup
{
    [self convertAllIntervalsToNight:YES];
    
    //[self initializePersonScheduleIndexes];
    [self createDayAndNightIntervalArrays];
    
    //[self resetAssignments];
    
    [self calculateNumNightIntervalsEachPersonIsAvailableAndResetAssignments:YES];
    [self calculateNumDayIntervalsEachPersonIsAvailableAndResetAssignments:YES];
    
    return true;
}
/*
 -(void)initializePersonScheduleIndexes
 {
 for(int p = 0; p<self.numPeople;p++){
 Person *person = self.personsArray[p];
 person.scheduleIndex = p;
 }
 }
 */

//TODO: edit response to allow algorithm to continue if not all required persons are available, by changing required perons to personsAvailable in that interval if its less than required persons
-(BOOL)checkForError
{
    BOOL error = false;
    for(int i = 0; i<self.numTotalIntervals;i++){
        AlgorithmInterval *interval = self.intervalDataByOverallRow[i];
        if(interval.numPersonsAvailable<interval.requiredPersons){
            //NSLog(@"Not enough people in interval %d", i);
            error = true;
        }
        
    }
    return error;
}


#pragma mark - Generate Schedule
-(NSMutableArray *)generateAssignments
{
    // Ideal Slots arrays
    [self generateNightAssignments];
    //[self generateDayAssignments];
    
    return self.personsArray;
    
}

-(void)createDayAndNightIntervalArrays
{
    NSUInteger numDayIntervals = 0;
    BOOL lastIntervalWasNight = false;
    for(int i = 0; i<self.numTotalIntervals; i++){
        AlgorithmInterval *interval = self.intervalDataByOverallRow[i];
        interval.overallIndex = i;
        if(interval.night){
            // Add Interval to Nights
            [self.nightIntervalsArray addObject:interval];
            lastIntervalWasNight = true;
            
        }else{
            if(lastIntervalWasNight || i == 0) [self.arrayOfDayIntervalsArrays addObject:[[NSMutableArray alloc]init]];
            
            // Add Interval to last day made so far
            NSMutableArray *dayIntervals = self.arrayOfDayIntervalsArrays.lastObject;
            [dayIntervals addObject:interval];
            numDayIntervals +=1;
            lastIntervalWasNight = false;
        }
    }
    
    self.numDayIntervals = numDayIntervals;
}

-(void)generateNightAssignments

{
    self.idealSlotsArrayNight = [self generateIdealSlotsArrayNight:YES];
    
    // Initial Assignments
    [self assignNightIntervals];
    
    // Calculate Assignment Sums
    [self calculateNumNightIntervalsEachPersonIsAssigned];;
    //[self calculateAssignIntervalSums];
    
    // Swap
    [self swapNightIntervalsUntilEqualityIsSufficient];
    
    
    
    // Re-calculate Assignment Sums
    [self calculateNumNightIntervalsEachPersonIsAssigned];
    //[self calculateAssignIntervalSums];
    
}
-(void)generateDayAssignments
{
    self.idealSlotsArrayDay = [self generateIdealSlotsArrayNight:NO];
    
    // Initial Assignments
    [self assignDayIntervals];
    
    // Calculate Assignment Sums
    // [self calculateNumDayIntervalsEachPersonIsAssigned];
    
    // Swap
    //[self swapDayIntervalsUntilEqualityIsSufficient];
    
    // Re-calculate Assignment Sums (for testing)
    //[self calculateNumNightIntervalsEachPersonIsAssigned];
    
    
    // Swap solos
    
    
    
}
-(NSMutableArray *)initializeIdealSlotsArray
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
    for(int i = 0; i<self.numPeople;i++){
        [array addObject:@-1];
    }
    return array;
    
}

//TODO: implement
-(NSUInteger)totalRequiredPersonsForDayIntervals
{
    return 0;
}

-(NSUInteger)totalRequiredPersonsForNightIntervals
{
    return 0;
}

-(NSMutableArray *)generateIdealSlotsArrayNight:(BOOL)night
{
    NSUInteger numIntervals;
    NSMutableArray *numIntervalsEachPersonIsAvailable;
    if(night){
        numIntervals = self.nightIntervalsArray.count;
        numIntervalsEachPersonIsAvailable = self.numNightIntervalsEachPersonIsAvailable;
    }else{
        numIntervals = self.numDayIntervals;
        numIntervalsEachPersonIsAvailable = self.numDayIntervalsEachPersonIsAvailable;
    }
    //TODO: test this with edge cases
    NSMutableArray *idealSlotsArray = [self initializeIdealSlotsArray];
    double totalSlotsRequired = self.requiredPersonsPerInterval*numIntervals;
    double idealSlotsPerRemainingPerson = totalSlotsRequired/self.numPeople;
    double numPeopleLeft = self.numPeople;
    double numSlotsLeft = totalSlotsRequired;
    BOOL changed = true;
    while(changed==true){
        changed = false;
        for(int p = 0; p<self.numPeople;p++){
            
            if([idealSlotsArray[p] isEqual:@-1] && [numIntervalsEachPersonIsAvailable[p] intValue] <= idealSlotsPerRemainingPerson ){
                
                idealSlotsArray[p] = numIntervalsEachPersonIsAvailable[p];
                numPeopleLeft--;
                numSlotsLeft -= [idealSlotsArray[p] intValue];
                changed = true;
                
            }
            
        }
        if(numPeopleLeft>0){
            idealSlotsPerRemainingPerson = numSlotsLeft/(numPeopleLeft);
        }
    }
    return [self fillRemainingPersonsInIdealSlotsArray:idealSlotsArray WithValue:idealSlotsPerRemainingPerson];
}
-(NSMutableArray *)fillRemainingPersonsInIdealSlotsArray:(NSMutableArray *)idealSlotsArray WithValue:(double)idealSlotsPerRemainingPerson
{
    for(int i = 0; i<idealSlotsArray.count;i++) {
        if([idealSlotsArray[i] isEqual:@-1]){
            idealSlotsArray[i]=[NSNumber numberWithDouble:idealSlotsPerRemainingPerson];
        }
    }
    return idealSlotsArray;
}

-(void)assignNightIntervals
{
    int assignCountInThisInterval;
    for(int i = 0; i<self.nightIntervalsArray.count;i++){
        AlgorithmInterval *interval = self.nightIntervalsArray[i];
        assignCountInThisInterval = 0;
        //for now, just assign intervals to first people available and then swap
        for(int p = 0; p<self.numPeople;p++){
            AlgorithmPerson *person = self.personsArray[p];
            if([person.assignmentsArray[interval.overallIndex] isEqual:@1]){
                person.assignmentsArray[interval.overallIndex]= @2;
                assignCountInThisInterval++;
            }
            if(assignCountInThisInterval==interval.requiredPersons) break;
            
        }
    }
}

// Change to to initial assignments in a better way
-(void)assignDayIntervals
{
    int assignCountInThisInterval;
    for(int d = 0; d<self.arrayOfDayIntervalsArrays.count;d++){
        NSMutableArray *dayDIntervals = self.arrayOfDayIntervalsArrays[d];
        for(int i = 0; i<dayDIntervals.count; i++){
            AlgorithmInterval *interval = dayDIntervals[i];
            assignCountInThisInterval = 0;
            //for now, just assign intervals to first people available and then swap
            for(int p = 0; p<self.numPeople;p++){
                AlgorithmPerson *person = self.personsArray[p];
                if([person.assignmentsArray[interval.overallIndex] isEqual:@1]){
                    person.assignmentsArray[interval.overallIndex] = @2;
                    assignCountInThisInterval++;
                }
                if(assignCountInThisInterval==interval.requiredPersons) break;
                
            }
        }
    }
}

-(void)swapSingleNightInterval:(AlgorithmInterval *)interval assignToPerson:(AlgorithmPerson *)personGainingInterval takeAwayFromPerson:(AlgorithmPerson *)personLosingInterval
{
    
    personGainingInterval.assignmentsArray[interval.overallIndex] = @2;
    personLosingInterval.assignmentsArray[interval.overallIndex] = @0;
    
    self.numNightIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] = [NSNumber numberWithInteger:[self.numNightIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] integerValue]+1];
    
    self.numNightIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex ] = [NSNumber numberWithInteger:[self.numNightIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex] integerValue] - 1];
    
    self.swapCountForCurrentPersonAttempt++;
}

-(void)swapSingleDayInterval:(AlgorithmInterval *)interval assignToPerson:(AlgorithmPerson *)personGainingInterval takeAwayFromPerson:(AlgorithmPerson *)personLosingInterval
{
    
    personGainingInterval.assignmentsArray[interval.overallIndex] = @2;
    personLosingInterval.assignmentsArray[interval.overallIndex] = @0;
    
    self.numDayIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] = [NSNumber numberWithInteger:[self.numDayIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] integerValue]+1];
    
    self.numDayIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex ] = [NSNumber numberWithInteger:[self.numDayIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex] integerValue] - 1];
    
    
    self.swapCountForCurrentPersonAttempt++;
}




//check this, probably edit it a bit
-(void)swapNightIntervalsUntilEqualityIsSufficient
{
    int swapAttemptsCount = 0; //# times looped through everthing and swapped when possible
    while(swapAttemptsCount<kTotalSwapAttemptsAllowed && ([self maximumValueInArray:self.numNightIntervalsEachPersonIsAssigned] - [self minimumValueInArray:self.numNightIntervalsEachPersonIsAssigned]) > ([self maximumValueInArray:self.idealSlotsArrayNight] - [self minimumValueInArray:self.idealSlotsArrayNight])){
        for(int p = 0; p<self.numPeople;p++){
            AlgorithmPerson *person = self.personsArray[p];
            self.swapCountForCurrentPersonAttempt = 1; //maybe change this to a boolean (swapped at least o once or no swap)
            while(self.swapCountForCurrentPersonAttempt > 0  && fabsf([self.idealSlotsArrayNight[person.scheduleIndex] floatValue] - [self.numNightIntervalsEachPersonIsAssigned[person.scheduleIndex] floatValue]) > kES){
                self.swapCountForCurrentPersonAttempt = 0;
                
                [self attemptAllNightSwapsForPerson:person consecutiveParameter:0];
            }
            
        }
        swapAttemptsCount++;
    }
}
//check this, probably edit it a bit
-(void)swapDayIntervalsUntilEqualityIsSufficient
{
    int swapAttemptsCount = 0; //# times looped through everthing and swapped when possible
    while(swapAttemptsCount<kTotalSwapAttemptsAllowed && ([self maximumValueInArray:self.numNightIntervalsEachPersonIsAssigned] - [self minimumValueInArray:self.numNightIntervalsEachPersonIsAssigned]) > ([self maximumValueInArray:self.idealSlotsArrayNight] - [self minimumValueInArray:self.idealSlotsArrayNight])){
        for(int p = 0; p<self.numPeople;p++){
            AlgorithmPerson *person = self.personsArray[p];
            self.swapCountForCurrentPersonAttempt = 1; //maybe change this to a boolean (swapped at least o once or no swap)
            while(self.swapCountForCurrentPersonAttempt > 0  && fabsf([self.idealSlotsArrayNight[person.scheduleIndex] floatValue] - [self.numNightIntervalsEachPersonIsAssigned[person.scheduleIndex] floatValue]) > kES){
                self.swapCountForCurrentPersonAttempt = 0;
                
                [self attemptAllNightSwapsForPerson:person consecutiveParameter:1];
            }
            
        }
        swapAttemptsCount++;
    }
}

-(void)attemptAllNightSwapsForPerson:(AlgorithmPerson *)person1 consecutiveParameter:(NSUInteger)consecutiveParameter
{
    for(int p2=0;p2<self.numPeople;p2++){
        AlgorithmPerson *person2 = self.personsArray[p2];
        if([self.numNightIntervalsEachPersonIsAssigned[person1.scheduleIndex] integerValue]<[self.idealSlotsArrayNight[person1.scheduleIndex] floatValue] && [self.numNightIntervalsEachPersonIsAssigned[person2.scheduleIndex] integerValue] >[self.idealSlotsArrayNight[person2.scheduleIndex] floatValue]){
            
            [self swapNightsUsingConsecutiveParameter:consecutiveParameter assignIntervalsTo:person1 takeAwayFrom:person2];
        }
        else if([self.numNightIntervalsEachPersonIsAssigned[person1.scheduleIndex] integerValue]>[self.idealSlotsArrayNight[person1.scheduleIndex]floatValue] && [self.numNightIntervalsEachPersonIsAssigned[person2.scheduleIndex] integerValue] <[self.idealSlotsArrayNight[person2.scheduleIndex] floatValue]){
            
            [self swapNightsUsingConsecutiveParameter:consecutiveParameter assignIntervalsTo:person2 takeAwayFrom:person1];
        }
    }
}

-(void)swapNightsUsingConsecutiveParameter:(NSUInteger)consecutiveParameter assignIntervalsTo:(AlgorithmPerson *)personGainingIntervals takeAwayFrom:(AlgorithmPerson *)personLosingIntervals
{
    if(consecutiveParameter == 0){
        //just care about equality
        [self swapAnyNightIntervalsIfPossibleAssignIntervalTo:personGainingIntervals takeAwayFrom:personLosingIntervals];
    }else if(consecutiveParameter == 1){
        // only swap from ends of consecutive assigned slots
        [self swapNightsFromBeginningIfPossibleAssignIntervalTo:personGainingIntervals takeAwayFrom:personLosingIntervals];
        [self swapNightsFromEndIfPossibleAssignIntervalTo:personGainingIntervals takeAwayFrom:personLosingIntervals];
    }else if (consecutiveParameter == 2){
        // only swap from ends of consecutive assigned slots, and only swap if can swap minConsecInMinues
    }
}

-(void)attemptAllDayIntervalSwapsForPerson:(AlgorithmPerson *)person1
{
    for(int p2=0;p2<self.numPeople;p2++){
        AlgorithmPerson *person2 = self.personsArray[p2];
        if([self.numNightIntervalsEachPersonIsAssigned[person1.scheduleIndex] integerValue]<[self.idealSlotsArrayNight[person1.scheduleIndex] floatValue] && [self.numNightIntervalsEachPersonIsAssigned[person2.scheduleIndex] integerValue] >[self.idealSlotsArrayNight[person2.scheduleIndex] floatValue]){
            [self swapNightsFromBeginningIfPossibleAssignIntervalTo:person1 takeAwayFrom:person2];
            [self swapNightsFromEndIfPossibleAssignIntervalTo:person1 takeAwayFrom:person2];
        }
        else if([self.numNightIntervalsEachPersonIsAssigned[person1.scheduleIndex] integerValue]>[self.idealSlotsArrayNight[person1.scheduleIndex]floatValue] && [self.numNightIntervalsEachPersonIsAssigned[person2.scheduleIndex] integerValue] <[self.idealSlotsArrayNight[person2.scheduleIndex] floatValue]){
            [self swapNightsFromBeginningIfPossibleAssignIntervalTo:person2 takeAwayFrom:person1];
            [self swapNightsFromEndIfPossibleAssignIntervalTo:person2 takeAwayFrom:person1];
        }
    }
}

-(BOOL)person:(AlgorithmPerson *)person isAvailableButNotAssignedInInterval:(AlgorithmInterval *)interval
{
    if([person.assignmentsArray[interval.overallIndex] integerValue] == 1){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)person:(AlgorithmPerson *)person isAvailableInInterval:(AlgorithmInterval *)interval
{
    if([person.assignmentsArray[interval.overallIndex] integerValue] == 1 ||  [person.assignmentsArray[interval.overallIndex] integerValue] == 2){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)person:(AlgorithmPerson *)person isAssignedInInterval:(AlgorithmInterval *)interval
{
    if([person.assignmentsArray[interval.overallIndex] integerValue] == 2){
        return YES;
    }else{
        return NO;
    }
}

-(void)swapAnyNightIntervalsIfPossibleAssignIntervalTo:(AlgorithmPerson *)personGainingInterval takeAwayFrom:(AlgorithmPerson *)personLosingInterval
{
    for(int i = 0;i<self.nightIntervalsArray.count;i++){ // shouldn't it just by i < self.nightIntervalsArray.count? instead of .count - 1
        AlgorithmInterval *interval = self.nightIntervalsArray[i];
        
        //changed condition to be less than ceil/floor int value of ideal slots array
        if([self.numNightIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] integerValue] >= ceil([self.idealSlotsArrayNight[personGainingInterval.scheduleIndex] floatValue]) || [self.numNightIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex] integerValue] <= ceil([self.idealSlotsArrayNight[personLosingInterval.scheduleIndex] floatValue])){
            return;
        }
        
        //if person1 is free but not assigned to this interval && person2 is assigned to this interval
        if([self person:personGainingInterval isAvailableButNotAssignedInInterval:interval] && [self person:personLosingInterval isAssignedInInterval:interval]){
            
            //switch intervals
            [self swapSingleNightInterval:interval assignToPerson:personGainingInterval takeAwayFromPerson:personLosingInterval];
        }
        
        
    }
    
}

-(void)swapNightsFromBeginningIfPossibleAssignIntervalTo:(AlgorithmPerson *)personGainingInterval takeAwayFrom:(AlgorithmPerson *)personLosingInterval
{
    for(int i = 0;i<self.nightIntervalsArray.count;i++){ // shouldn't it just by i < self.nightIntervalsArray.count? instead of .count - 1
        AlgorithmInterval *interval = self.nightIntervalsArray[i];
        AlgorithmInterval *previousNightInterval = (i - 1) >= 0 ? self.nightIntervalsArray[i-1] : nil;
        //changed condition to be less than ceil/floor int value of ideal slots array
        
        if([self.numNightIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] integerValue] >= ceil([self.idealSlotsArrayNight[personGainingInterval.scheduleIndex] floatValue]) || [self.numNightIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex] integerValue] <= ceil([self.idealSlotsArrayNight[personLosingInterval.scheduleIndex] floatValue])){
            return;
        }
        /*
         if([self.numNightIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] integerValue] >= [self.numNightIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex] integerValue] ){
         return;
         }*/
        
        
        //if person1 is free but not assigned to this interval && person2 is assigned to this interval
        if([self person:personGainingInterval isAvailableButNotAssignedInInterval:interval] && [self person:personLosingInterval isAssignedInInterval:interval]){
            
            //if person2 is not assigned to the previous interval or it's the first interval
            if(i == 0 || ![self person:personLosingInterval isAssignedInInterval:previousNightInterval]){
                
                //switch intervals
                [self swapSingleNightInterval:interval assignToPerson:personGainingInterval takeAwayFromPerson:personLosingInterval];
            }
        }
        
        
    }
    
}

-(void)swapNightsFromEndIfPossibleAssignIntervalTo:(AlgorithmPerson *)personGainingInterval takeAwayFrom:(AlgorithmPerson *)personLosingInterval
{
    //change to allow ends to be swapped
    for(NSInteger i = self.nightIntervalsArray.count - 1; i>=0;i--){ // shouldn't it be i >=0? instead of > 0
        AlgorithmInterval *interval = self.nightIntervalsArray[i];
        AlgorithmInterval *previousNightInterval = (i + 1) < self.nightIntervalsArray.count ? self.nightIntervalsArray[i+1] : nil;
        
        
        if([self.numNightIntervalsEachPersonIsAssigned[personGainingInterval.scheduleIndex] integerValue] >= ceil([self.idealSlotsArrayNight[personGainingInterval.scheduleIndex] floatValue]) || [self.numNightIntervalsEachPersonIsAssigned[personLosingInterval.scheduleIndex] integerValue] <= ceil([self.idealSlotsArrayNight[personLosingInterval.scheduleIndex] floatValue])){
            return;
        }
        
        //if person1 is free but not assigned to this interval && person2 is assigned to this interval
        if([self person:personGainingInterval isAvailableButNotAssignedInInterval:interval] && [self person:personLosingInterval isAssignedInInterval:interval]){
            
            //if person2 is not assigned to the previous (chronologically, next) interval or it's the last interval
            if((i == self.nightIntervalsArray.count-1) || ![self person:personLosingInterval isAssignedInInterval:previousNightInterval]){ //this is so that it doesn't break up a consecutive streak to swap
                
                //switch intervals
                [self swapSingleNightInterval:interval assignToPerson:personGainingInterval takeAwayFromPerson:personLosingInterval];
            }
        }
    }
    
}

-(void)swapDayIntervalsFromBeginningIfPossibleAssignIntervalTo:(AlgorithmPerson *)personGainingInterval takeAwayFrom:(AlgorithmPerson *)personLosingInterval
{
    
}
-(void)swapDayIntervalsFromEndIfPossibleAssignIntervalTo:(AlgorithmPerson *)personGainingInterval takeAwayFrom:(AlgorithmPerson *)personLosingInterval
{
    
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


#pragma mark - Sums

-(void)calculateNumNightIntervalsEachPersonIsAvailableAndResetAssignments:(BOOL)reset{
    for(int p = 0;p<self.numPeople;p++){
        int availSums = 0;
        for(int n = 0; n<self.nightIntervalsArray.count;n++){
            AlgorithmPerson *person = self.personsArray[p];
            AlgorithmInterval *interval = self.nightIntervalsArray[n];
            NSUInteger overallIndex = interval.overallIndex;
            if ([person.assignmentsArray[overallIndex] integerValue]== 1 || [person.assignmentsArray[overallIndex] integerValue] == 2){
                availSums += 1;
                if(reset){
                    person.assignmentsArray[overallIndex] = @1; //takes care of resetting assignments schedule. maybe move to new method (this would make it clearer, but also less efficient)
                    
                    
                }
            }
        }
        self.numNightIntervalsEachPersonIsAvailable[p] = [NSNumber numberWithInteger:availSums];
        
    }
    
}
-(void)calculateNumNightIntervalsEachPersonIsAssigned{
    for(int p = 0;p<self.numPeople;p++){
        int assignSums = 0;
        for(int n = 0; n<self.nightIntervalsArray.count;n++){
            AlgorithmPerson *person = self.personsArray[p];
            AlgorithmInterval *interval = self.nightIntervalsArray[n];
            NSUInteger overallIndex = interval.overallIndex;
            if ([person.assignmentsArray[overallIndex] integerValue] == 2){
                assignSums += 1;
            }
        }
        self.numNightIntervalsEachPersonIsAssigned[p] = [NSNumber numberWithInteger:assignSums];
        
    }
    
}
-(void)calculateNumDayIntervalsEachPersonIsAvailableAndResetAssignments:(BOOL)reset{
    for(int p = 0;p<self.numPeople;p++){
        int availSums = 0;
        for(int d = 0; d<self.arrayOfDayIntervalsArrays.count;d++){
            NSMutableArray *dayDIntervals = self.arrayOfDayIntervalsArrays[d];
            for(int i = 0; i<dayDIntervals.count; i++){
                AlgorithmPerson *person = self.personsArray[p];
                AlgorithmInterval *interval = dayDIntervals[i];
                NSUInteger overallIndex = interval.overallIndex;
                if ([person.assignmentsArray[overallIndex] integerValue]== 1 || [person.assignmentsArray[overallIndex] integerValue] == 2){
                    availSums += 1;
                    if(reset) {
                        person.assignmentsArray[overallIndex] = @1; //takes care of resetting assignments schedule. maybe move to new method (this would make it clearer, but also less efficient)
                        
                    }
                }
                
            }
        }
        self.numDayIntervalsEachPersonIsAvailable[p] = [NSNumber numberWithInteger:availSums];
        
    }
    
}
-(void)calculateNumDayIntervalsEachPersonIsAssigned{
    for(int p = 0;p<self.numPeople;p++){
        int assignSums = 0;
        for(int d = 0; d<self.arrayOfDayIntervalsArrays.count;d++){
            NSMutableArray *dayDIntervals = self.arrayOfDayIntervalsArrays[d];
            for(int i = 0; i<dayDIntervals.count; i++){
                AlgorithmPerson *person = self.personsArray[p];
                AlgorithmInterval *interval = dayDIntervals[i];
                NSUInteger overallIndex = interval.overallIndex;
                if ([person.assignmentsArray[overallIndex] integerValue] == 2){
                    assignSums += 1;
                }
                
            }
        }
        self.numDayIntervalsEachPersonIsAssigned[p] = [NSNumber numberWithInteger:assignSums];
        
    }
}

/*
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
 */

@end
