//
//  Schedule.m
//  Tent
//
//  Created by Jeremy on 7/23/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "Schedule.h"
#import "Interval.h"
#import "Constants.h"

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
-(NSMutableArray *)personsArray
{
    if(!_personsArray)_personsArray = [[NSMutableArray alloc]init];
    return _personsArray;
}


-(void)createIntervalDataArrays
{
    
    NSMutableArray *intervalDataByOverallRow = [[NSMutableArray alloc]init];
    /*
     [Interval, Interval,...]
     */
    NSMutableDictionary *intervalDataBySection = [[NSMutableDictionary alloc]init]; //{index (integer):["section header ex: Mon Oct. 17", [intervalDisplayArrayForThatSection]]}
    //TODO: edit to dict inside (maybe json). and add numRowsAtStart to each section so I can calculate true indexpath.row later
    /*
     {
     sectionIndex:
     {
     
     day: NSDate
     sectionHeader: NSString
     intervalStartIndex: NSUInteger
     intervalEndIndex: NSUInteger (
     (if contains intervals 0, 1,2,3,4, start = 0, end = 5
     //numIntervalsBeforeDay: startIndex
     //numIntervalsInDay: endIndex - startIndex
     //intervals: [Interval, Interval] //this is copy of intervalDataByOverRow data. I guess I could just store start and end index of section
     }
     }
     */
    NSMutableArray *sectionIntervals = [[NSMutableArray alloc]init];
    
    NSDate *currentStartInterval = [self.startDate copy];
    NSDate *previousStartInterval = currentStartInterval;
    NSDate *currentEndInterval = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:currentStartInterval];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponentsCurrent;
    NSDateComponents *dateComponentsPrevious;
    
    NSString *sectionHeader = [Constants formatDate:currentStartInterval withStyle:NSDateFormatterShortStyle];
    NSDate *sectionDate = [currentStartInterval copy];
    NSUInteger sectionNumber = 0;
    NSUInteger intervalStartIndex = 0;
    
    for(int i = 0; i<self.numHourIntervals;i++){
        dateComponentsPrevious = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:previousStartInterval];
        dateComponentsCurrent = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:currentStartInterval];
        
        if(dateComponentsPrevious.day != dateComponentsCurrent.day) { //i.e. oct 17, oct 18. compare 17 and 18
            
            //Add current section data to dict and initialize new section
            
            NSMutableDictionary *sectionData = [self sectionDictForDay:sectionDate sectionHeader:sectionHeader intervalStartIndex:intervalStartIndex intervalEndIndex:i];
            
            [intervalDataBySection setObject:sectionData forKey:[NSNumber numberWithInteger:sectionNumber]];
            
            //Initialize next section
            sectionHeader = [Constants formatDate:currentStartInterval withStyle:NSDateFormatterShortStyle];
            sectionDate = [currentStartInterval copy];
            sectionIntervals = [[NSMutableArray alloc]init];
            intervalStartIndex = i;
            sectionNumber++;

        }
        
        Interval *interval = [[Interval alloc]initWithStartDate:currentStartInterval endDate:currentEndInterval section:sectionNumber];
        [intervalDataByOverallRow addObject:interval];
        [sectionIntervals addObject:interval];
        
        previousStartInterval = currentStartInterval;
        currentStartInterval = currentEndInterval;
        currentEndInterval = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:currentStartInterval];
        NSTimeInterval timeUntilEnd = [self.endDate timeIntervalSinceDate:currentEndInterval];
        
        
        if(timeUntilEnd <= 0 ){
            Interval *interval = [[Interval alloc]initWithStartDate:currentStartInterval endDate:self.endDate section:sectionNumber];
            [intervalDataByOverallRow addObject:interval];
            [sectionIntervals addObject:interval];
            
            NSMutableDictionary *sectionData = [self sectionDictForDay:sectionDate sectionHeader:sectionHeader intervalStartIndex:intervalStartIndex intervalEndIndex:i+1];
            
            [intervalDataBySection setObject:sectionData forKey:[NSNumber numberWithInteger:sectionNumber]];
            
        }
        
    }
    
    self.intervalDataBySection = [intervalDataBySection copy];
    self.intervalDataByOverallRow = [intervalDataByOverallRow copy];
    
}

-(NSMutableDictionary *)sectionDictForDay:(NSDate *)day sectionHeader:(NSString *)sectionHeader intervalStartIndex:(NSUInteger) start intervalEndIndex: (NSUInteger) end
{
    NSMutableDictionary *sectionData = [[NSMutableDictionary alloc]init];
    sectionData[@"day"] = day;
    sectionData[@"sectionHeader"] = sectionHeader;
    sectionData[@"intervalStartIndex"] = [NSNumber numberWithInteger:start];
    sectionData[@"intervalEndIndex"] = [NSNumber numberWithInteger:end];

    return sectionData;
    
}

-(void)resetIntervalArray
{
    for(int i = 0;i<self.intervalDataByOverallRow.count;i++){
        Interval *interval = (Interval *)self.intervalDataByOverallRow[i];
        interval.assignedPersons = [[NSMutableArray alloc]init];
        interval.availablePersons = [[NSMutableArray alloc]init];
    }

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
        
        //intervalArray
            //[self createIntervalDisplayArray];
            //self.intervalArray = [self createZeroedIntervalArray];
            [self createIntervalDataArrays];
        
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
        NSUInteger numHourIntervals = ceil(time/3600);

         //call designated initializer
        self = [self initWithName:name availabilitiesSchedule:[[NSMutableArray alloc]init] assignmentsSchedule:nil numHourIntervals:numHourIntervals startDate:startDate endDate:endDate privacy:privacy password:password homeGameIndex:homeGameIndex parseObjectID:nil];
        
        
        
        
       
        
    }
    return self;

}
-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex creatorObjectID:(NSString *)creatorObjectID parseObjectID: (NSString *)parseObjectID
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
        
        //intervalArray
            //[self createIntervalDisplayArray];
            //self.intervalArray = [self createZeroedIntervalArray];
            [self createIntervalDataArrays];
        
        //store creator
        self.creatorObjectID = creatorObjectID;
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name availabilitiesSchedule:(NSMutableArray *)availabilitiesSchedule assignmentsSchedule:(NSMutableArray *)assignmentsSchedule numHourIntervals:(NSUInteger)numHourIntervals startDate:(NSDate *)startDate endDate:(NSDate *)endDate privacy:(NSString *)privacy password: (NSString *)password homeGameIndex: (NSUInteger)homeGameIndex admins:(NSArray *)admins parseObjectID: (NSString *)parseObjectID
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
        
        //intervalArray
            //[self createIntervalDisplayArray];
            //self.intervalArray = [self createZeroedIntervalArray];
            [self createIntervalDataArrays];
        
        
        //TODO: store admins
        
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

#pragma mark - formatting
-(NSString *)dateStringForSection:(NSUInteger)section
{
    NSMutableDictionary *sectionData = [self.intervalDataBySection objectForKey:[NSNumber numberWithInteger:section]];

    NSString *dateString = [Constants formatDate:sectionData[@"day"] withStyle:NSDateFormatterShortStyle];
    return dateString;
}
-(NSString *)timeStringForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *sectionData = [self.intervalDataBySection objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    
    NSUInteger startIndex = [sectionData[@"intervalStartIndex"] integerValue];
    
    NSUInteger index = startIndex + indexPath.row;
    Interval *interval = self.intervalDataByOverallRow[index];

    return interval.timeString;
}
-(NSString *)dateTimeStringForIndexPath:(NSIndexPath *)indexPath
{
    return [[[self dateStringForSection:indexPath.section] stringByAppendingString:@" "] stringByAppendingString:[self timeStringForIndexPath:indexPath]];
}
-(NSString *)dateTimeStringForOverallRow:(NSIndexPath *)indexPath
{
    Interval *interval = self.intervalDataByOverallRow[indexPath.row];
    
    return [[[self dateStringForSection:interval.section] stringByAppendingString:@" "] stringByAppendingString:interval.timeString];
}
@end
