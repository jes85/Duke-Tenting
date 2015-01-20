//
//  Schedule.m
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Schedule.h"
#import "Interval.h"
static const int kES = 1;
static const NSUInteger kTotalSwapAttemptsAllowed = 5;

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

// Swap
@property (nonatomic) NSUInteger swapCountForCurrentPersonAttempt;



@end

@implementation Schedule
#warning Internet Required to Generate schedule- Right now, the internet is required to generate schedule because the app does not locally save the availability schedules. This is only an issue if someone wants to do it all on one iPhone. Otherwise, internet is required anyway to sync individual people's schedules

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

-(NSMutableArray *) availabilitiesSchedule
{
    if(!_availabilitiesSchedule){
        _availabilitiesSchedule = [[NSMutableArray alloc]init];
    }
    return _availabilitiesSchedule;
}
-(NSMutableArray *) assignmentsSchedule
{
    if(!_assignmentsSchedule) _assignmentsSchedule = [[NSMutableArray alloc]init];
    return _assignmentsSchedule;
}

-(NSMutableArray *)createZeroesAssignmentsSchedule
{
    NSMutableArray *assignments = [[NSMutableArray alloc]initWithCapacity:self.numPeople];
    for(int p = 0; p<self.numPeople;p++){
        NSMutableArray *intervals = [[NSMutableArray alloc]initWithCapacity:self.numIntervals];
        [assignments addObject:intervals];
        for(int i = 0; i<self.numIntervals; i++){
            assignments[p][i]=@0;
        }
    }
    return assignments;
}

-(NSMutableArray *)intervalArray
{
    if(!_intervalArray)_intervalArray = [[NSMutableArray alloc]init];
    return _intervalArray;
}
-(NSArray *)hourIntervalsDisplayArray
{
    if(!_hourIntervalsDisplayArray)_hourIntervalsDisplayArray = [[NSArray alloc]init];
    return _hourIntervalsDisplayArray;
}
-(NSMutableArray *)createZeroedIntervalArray
{
    NSMutableArray *intervalArray = [[NSMutableArray alloc]init];
    for(int i = 0;i<self.numHourIntervals;i++){
        Interval *interval = [[Interval alloc]init];
        [intervalArray addObject:interval];
    }
   
    return intervalArray;
}

-(void)createIntervalDisplayArray
{
    NSDate *beginningHourDate = [self.startDate copy];
    NSDate *endHourDate = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:beginningHourDate];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for(int i = 0; i<self.numHourIntervals;i++){
        NSString *beginningHourString = [NSDateFormatter localizedStringFromDate:beginningHourDate dateStyle:0 timeStyle:NSDateFormatterShortStyle];
        NSString *endHourString = [NSDateFormatter localizedStringFromDate:endHourDate dateStyle:0 timeStyle:NSDateFormatterShortStyle];
        NSString *hourInterval = [NSString stringWithFormat:@"%@ - %@", beginningHourString, endHourString];
        [array addObject:hourInterval];
        beginningHourDate = endHourDate;
        endHourDate = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:beginningHourDate];
        
    }
    
    self.hourIntervalsDisplayArray = [array copy];
    
}

#pragma mark - init

//Designated initializer (maybe add a numPeople parameter)
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex parseObjectID: (NSString *)parseObjectID
{
    self = [super init];
    if(self){
        self.availabilitiesSchedule = availabilitiesSchedule;
        self.numPeople = [self.availabilitiesSchedule count];
        self.numHourIntervals = numHourIntervals; //get rid of one of these
        self.numIntervals = numHourIntervals;
        self.startDate = startDate;
        self.endDate = endDate;
        self.homeGameIndex = homeGameIndex;
        self.privacy = privacy;
        self.password = password;
        
        self.parseObjectID = parseObjectID;
        
        
        if(assignmentsSchedule){
            self.assignmentsSchedule = assignmentsSchedule;
        }
        else{
            self.assignmentsSchedule = [self createZeroesAssignmentsSchedule];
        }
        self.name = name;
        
        //intervalArray/hourIntervalDisplayArray
        [self createIntervalDisplayArray];
        self.intervalArray = [self createZeroedIntervalArray];
        
        //maybe create actual interval array: 2 options
        //1. make personsArray a property of Schedule (that way we can eliminate the need for a "Person" object in Parse
        //2. add 2 properties to Interval: arrays of available/assigned person INDICES. then when loading the people, add their names to array of available/assigned person NAMES if their index is in available/assigned person INDICES for that interval
        //(this one doesn't make much sense to do because it's not more efficient than just creating the array of NAMES for each interval  when querying for Persons
        
        
        
        
    }
    return self;
}
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex:(NSUInteger)homeGameIndex{
    self = [super init];
    if(self){
       
        
        //call designated initializer
        self = [self initWithName:name availabilitiesSchedule:availabilitiesSchedule assignmentsSchedule:assignmentsSchedule numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex parseObjectID:nil];
        
        
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex
{
    self = [super init];
    if(self){
        
        
        double time = [endDate timeIntervalSinceDate:startDate];
        NSUInteger numHourIntervals = (NSUInteger)time/3600;

         //call designated initializer
        self = [self initWithName:name availabilitiesSchedule:[[NSMutableArray alloc]init] assignmentsSchedule:nil numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex parseObjectID:nil];
        
        
        
        
       
        
    }
    return self;

}

#pragma mark - Setup methods

-(BOOL)setup
{
    
    self.assignmentsSchedule = [self createZeroesAssignmentsSchedule];
    
    
    // PPI
        self.requiredPersonsPerInterval = ceil(self.numPeople/3.0);
    
    
    // Sums Arrays
        [self calculateAvailIntervalSums];
        [self calculateAvailPeopleSums];

    // Check Error
        if([self checkForError]) return false;
    
    // Ideal Slots arrays
        [self generateIdealSlotsArray];

    // Generate Schedule
        [self generateSchedule];
    
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
-(void)generateSchedule
{
    
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
    
}

-(void)assignIntervals
{
    int assignCountInThisInterval;
    //sort availPeopleSums
    for(int i = 0; i<self.numIntervals;i++){
        assignCountInThisInterval = 0;
        //for now, just assign intervals to first people available and then swap
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
        //changed condition to be less than ceil/floor int value of ideal slots array
        if(([self.assignPeopleSums[personGainingInterval] integerValue]>=ceil([self.idealSlotsArray[personGainingInterval] floatValue])) || ([self.assignPeopleSums[personLosingInterval] integerValue] <= ceil([self.idealSlotsArray[personLosingInterval] floatValue]))){
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
    for(NSUInteger i = self.numIntervals-1; i>0;i--){
        if([self.assignPeopleSums[personGainingInterval] integerValue] >= ceil([self.idealSlotsArray[personGainingInterval ] floatValue]) || [self.assignPeopleSums[personLosingInterval] integerValue] <= ceil([self.idealSlotsArray[personLosingInterval] floatValue])){
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

#pragma mark - Equality
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToSchedule:other];
}

- (BOOL)isEqualToSchedule:(Schedule *)aSchedule {
    if (self == aSchedule)
        return YES;
    if (![(id)[self name] isEqual:[aSchedule name]])
        return NO;
    if (!([self startDate] == [aSchedule startDate]))
        return NO;
    if (![(id)[self endDate] isEqual:[aSchedule endDate]])
        return NO;
    //add more
    // NSLog(@"Test equality");
    return YES;
}




@end
