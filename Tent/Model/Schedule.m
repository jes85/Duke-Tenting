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
#import "Person.h"
@interface Schedule()


@end

@implementation Schedule

//TODO: v2: option to generate schedule without internet. Rsight now, the internet is required to generate schedule because the app does not locally save the availability schedules. This is only an issue if someone wants to do it all on one iPhone. Otherwise, internet is required anyway to sync individual people's schedules

/*
 just need to do this when initializing each person
    if person.assignmentsArray
        person.assignmentsArray = person.assignmentsArray
    else
        person.assignmentsArray = createZeroesAssignmentsArray
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
 */
/*
-(NSMutableArray *)personsArray
{
    if(!_personsArray)_personsArray = [[NSMutableArray alloc]init];
    return _personsArray;
}
*/

#pragma mark - init

//Designated initializer

-(instancetype)initWithGroupName:(NSString *)name groupCode:(NSString *)groupCode startDate:(NSDate *)startDate endDate:(NSDate *)endDate intervalLengthInMinutes: (NSUInteger)intervalLength personsArray:(NSMutableArray *)personsArray homeGame:(HomeGame *)hg createdBy:(PFObject *)createdBy assignmentsGenerated:(BOOL)assignmentsGenerated parseObjectID:(NSString *)parseObjectID
{
    self = [super init];
    if(self){
        self.groupName = name;
        self.groupCode = groupCode;
        self.startDate = startDate;
        self.endDate = endDate;
        self.intervalLengthInMinutes = intervalLength;
        self.personsArray = personsArray;
        self.homeGame = hg;
        self.createdBy = createdBy;
        self.assignmentsGenerated = assignmentsGenerated;
        self.parseObjectID = parseObjectID;
        //self.currentUserPersonIndex = [self findCurrentUserPersonIndex];
        self.currentUserWasRemoved = false;
        //[self calculateNumIntervals];
        [self createIntervalDataArrays];
        
        //KVO to update interval data arrays every time personsArray is updated
        /*
        [self addObserver:self forKeyPath:kUserInfoLocalSchedulePropertyPersonsArray options:NSKeyValueObservingOptionNew context:nil];
         */
    }
    return self;
}
/*
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == self && [keyPath isEqualToString:@"personsArray"]){
        [self createIntervalDataArrays];
    }
    
}
 */
-(NSUInteger)findCurrentUserPersonIndex
{
    //NSLog(@"%@, %lu", self.groupName, (unsigned long)self.personsArray.count);
    for(int i = 0; i<self.personsArray.count; i++){
        Person *person = self.personsArray[i];
        //NSLog(@"%@", person.user.objectId);
        //NSLog(@"%@", [[PFUser currentUser] objectId]);

        if(person.user && [person.user.objectId isEqualToString:[[PFUser currentUser] objectId]]){
            return i;
        }
    }
    return -1; //helps catch errors: will throw a bug if it returns -1 because it will try to access an array index -1
    
}
/*
-(void)calculateNumIntervals
{
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceDate:self.startDate];
    NSUInteger minutes = ceil(timeInterval/60);
    NSUInteger numIntervals =  minutes / self.intervalLengthInMinutes;
    self.numIntervals = minutes % self.intervalLengthInMinutes == 0 ? numIntervals : numIntervals + 1;
}
 */
-(NSUInteger)requiredPersonsPerInterval
{
    return ceil(self.personsArray.count / 3.0);
    
}
#pragma mark - UI Helpers and Formatting

//{endDate:date, night: bool}
-(NSDictionary *)intervalEndDateForIntervalStartDate:(NSDate *)intervalStartDate
{
   

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = calendar.timeZone;
    NSDateComponents *intervalStartDateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitMonth  | NSCalendarUnitDay | NSCalendarUnitYear  ) fromDate:intervalStartDate];
   
    NSDateComponents *nightStartDateComponents = [[NSDateComponents alloc]init];
    [nightStartDateComponents setHour:23];
    [nightStartDateComponents setMinute :0];
    [nightStartDateComponents setYear:intervalStartDateComponents.year];
    [nightStartDateComponents setMonth: intervalStartDateComponents.month];
    [nightStartDateComponents setDay: intervalStartDateComponents.day];
    NSDate *nightStartDate = [calendar dateFromComponents:nightStartDateComponents];
    NSDate *nightEndDate = [NSDate dateWithTimeInterval:60*60*8 sinceDate:nightStartDate];
    
    NSDate *intervalEndDateIfNormalLengthInterval = [NSDate dateWithTimeInterval:60*self.intervalLengthInMinutes sinceDate:intervalStartDate];
    // Cases
    
    NSDate *intervalEndDate;
    BOOL night;
    //Night Interval
    //if(intervalStartDateComponents.hour == nightStartHour & intervalStartDateComponents.minute == nightStartMinute){//11:00 pm - 7:00 AM
    if([intervalStartDate timeIntervalSinceDate: nightStartDate] == 0){
        //NSLog(@"Start Date: %@", [Constants formatDateAndTime:intervalStartDate withDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle] );
        //NSDate *intervalEndDate = [NSDate dateWithTimeInterval:60*60*8 sinceDate:intervalStartDate]; // 8 hours
        //NSLog(@"End Date: %@", [Constants formatDateAndTime:nightEndDate withDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle] );
        
        intervalEndDate = nightEndDate;
        night = YES;
    }
    
    //Short Interval Before Night Interval
    else if([nightStartDate timeIntervalSinceDate:intervalEndDateIfNormalLengthInterval] < 0 ){
        intervalEndDate = nightStartDate;
        night = NO;
    }
    
    //Normal Interval
    else{
        intervalEndDate = intervalEndDateIfNormalLengthInterval;
        night = NO;
        
    }
    intervalEndDate = [intervalEndDate timeIntervalSinceDate:self.endDate] < 0 ? intervalEndDate : self.endDate;
    return @{@"endDate":intervalEndDate, @"night":[NSNumber numberWithBool:night]};

}
//{endDate:date, night: bool}
-(NSDictionary *)intervalEndDateForIntervalStartDateUNC:(NSDate *)intervalStartDate
{
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *intervalStartDateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitMonth  | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitWeekday ) fromDate:intervalStartDate];
    
    NSDateComponents *nightStartDateComponents = [[NSDateComponents alloc]init];
    NSDate *nightStartDate;
    NSTimeInterval nightTimeInterval;
    
    

    //sunday, mon, tues 11 pm - 7 am
    if((intervalStartDateComponents.weekday == 1 && intervalStartDateComponents.hour > 2) || intervalStartDateComponents.weekday == 2 || intervalStartDateComponents.weekday == 3){ //sunday after 2:30 am, monday, tuesday
        [nightStartDateComponents setHour:23];
        [nightStartDateComponents setMinute :0];
        [nightStartDateComponents setYear:intervalStartDateComponents.year];
        [nightStartDateComponents setMonth: intervalStartDateComponents.month];
        [nightStartDateComponents setDay: intervalStartDateComponents.day];
        nightTimeInterval = 60*60*8; //8 hours

        

    }
    //wed, thurs 2:30 am - 7 am
    else if( intervalStartDateComponents.weekday == 4 || intervalStartDateComponents.weekday == 5 || (intervalStartDateComponents.weekday == 6 && intervalStartDateComponents.hour < 3) ){ //wed, thurs, fri before 2:30 am
        NSDate *nextDay = [NSDate dateWithTimeInterval:60*60*24 sinceDate:intervalStartDate];
        NSDateComponents *nextDayDateComponents = [calendar components:(NSCalendarUnitMonth  | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:nextDay];

        [nightStartDateComponents setHour:2];
        [nightStartDateComponents setMinute :30];
        if(intervalStartDateComponents.hour < 2 || (intervalStartDateComponents.hour ==2 && intervalStartDateComponents.minute <= 30)){ // if before 2:30 am, night is on same day
            [nightStartDateComponents setYear:intervalStartDateComponents.year];
            [nightStartDateComponents setMonth: intervalStartDateComponents.month];
            [nightStartDateComponents setDay: intervalStartDateComponents.day];
        }else{
            [nightStartDateComponents setYear:nextDayDateComponents.year];
            [nightStartDateComponents setMonth: nextDayDateComponents.month];
            [nightStartDateComponents setDay: nextDayDateComponents.day];
        }
        nightTimeInterval = 60*60*4 + 60*30; //4.5 hours
    }
    //fri,saturday 2:30 am - 10 am
    else if((intervalStartDateComponents.weekday == 6 && intervalStartDateComponents.hour > 2) || intervalStartDateComponents.weekday == 7 || (intervalStartDateComponents.weekday == 1 && intervalStartDateComponents.hour < 3)){ //fri after 2:30 am, sat, sun before 2:30 am
        NSDate *nextDay = [NSDate dateWithTimeInterval:60*60*24 sinceDate:intervalStartDate];
        NSDateComponents *nextDayDateComponents = [calendar components:(NSCalendarUnitMonth  | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:nextDay];
        
        [nightStartDateComponents setHour:2];
        [nightStartDateComponents setMinute :30];
        if(intervalStartDateComponents.hour < 2 || (intervalStartDateComponents.hour ==2 && intervalStartDateComponents.minute <= 30)){ // if before 2:30 am, night is on same day
            [nightStartDateComponents setYear:intervalStartDateComponents.year];
            [nightStartDateComponents setMonth: intervalStartDateComponents.month];
            [nightStartDateComponents setDay: intervalStartDateComponents.day];
        }else{
            [nightStartDateComponents setYear:nextDayDateComponents.year];
            [nightStartDateComponents setMonth: nextDayDateComponents.month];
            [nightStartDateComponents setDay: nextDayDateComponents.day];
        }

        nightTimeInterval = 60*60*7 + 60*30; //7.5 hours

    }
    nightStartDate =[calendar dateFromComponents:nightStartDateComponents];
    
    NSDate *nightEndDate = [NSDate dateWithTimeInterval:nightTimeInterval sinceDate:nightStartDate];

    NSDate *intervalEndDateIfNormalLengthInterval = [NSDate dateWithTimeInterval:60*self.intervalLengthInMinutes sinceDate:intervalStartDate];
    // Cases
    
    NSDate *intervalEndDate;
    BOOL night;
    //Night Interval
    //if(intervalStartDateComponents.hour == nightStartHour & intervalStartDateComponents.minute == nightStartMinute){//11:00 pm - 7:00 AM
    if([intervalStartDate timeIntervalSinceDate: nightStartDate] == 0){
        //NSLog(@"Start Date: %@", [Constants formatDateAndTime:intervalStartDate withDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle] );
        //NSDate *intervalEndDate = [NSDate dateWithTimeInterval:60*60*8 sinceDate:intervalStartDate]; // 8 hours
        //NSLog(@"End Date: %@", [Constants formatDateAndTime:nightEndDate withDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle] );
        
        intervalEndDate = nightEndDate;
        night = YES;
    }
    
    //Short Interval Before Night Interval
    else if([nightStartDate timeIntervalSinceDate:intervalEndDateIfNormalLengthInterval] < 0 ){
        intervalEndDate = nightStartDate;
        night = NO;
    }
    
    //Normal Interval
    else{
        intervalEndDate = intervalEndDateIfNormalLengthInterval;
        night = NO;
        
    }
    intervalEndDate = [intervalEndDate timeIntervalSinceDate:self.endDate] < 0 ? intervalEndDate : self.endDate;
    return @{@"endDate":intervalEndDate, @"night":[NSNumber numberWithBool:night]};
    
}
-(NSUInteger)requiredPersonsForUNCInterval:(Interval *)interval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *tentingPeriodsStartDateComponents = [[NSDateComponents alloc]init];
    [tentingPeriodsStartDateComponents setYear:2016];
    
    //black tenting
    [tentingPeriodsStartDateComponents setMonth:1];
    [tentingPeriodsStartDateComponents setDay:17];
    [tentingPeriodsStartDateComponents setHour:23];
    
    NSDate *blackTentingStartDate = [calendar dateFromComponents:tentingPeriodsStartDateComponents];
    
    
    
    //buetenting
    [tentingPeriodsStartDateComponents setMonth:1];
    [tentingPeriodsStartDateComponents setDay:31];
    [tentingPeriodsStartDateComponents setHour:23];
    
    NSDate *blueTentingStartDate = [calendar dateFromComponents:tentingPeriodsStartDateComponents];
    //black tenting
    [tentingPeriodsStartDateComponents setMonth:2];
    [tentingPeriodsStartDateComponents setDay:17];
    [tentingPeriodsStartDateComponents setHour:23];
    
    NSDate *whiteTentingStartDate = [calendar dateFromComponents:tentingPeriodsStartDateComponents];
    
    [tentingPeriodsStartDateComponents setMonth:3];
    [tentingPeriodsStartDateComponents setDay:2];
    [tentingPeriodsStartDateComponents setHour:12];
    
    NSDate *uncTentingEndDate = [calendar dateFromComponents:tentingPeriodsStartDateComponents];
    
    
    // Start Date is earlier than Black Tent Start Date
    if([interval.startDate timeIntervalSinceDate:blackTentingStartDate] < 0){
        return 0; //unc tenting has not started yet
    }else if([interval.startDate timeIntervalSinceDate:blueTentingStartDate] < 0){
        //black tenting: start date is equal to or greater than black tent start date and earlier than blue tent start date
        return interval.night ? 10 : 2;
    }else if([interval.startDate timeIntervalSinceDate:whiteTentingStartDate] < 0){
        // blue tenting
        return interval.night ? 6 : 1;
    }else if([interval.startDate timeIntervalSinceDate:uncTentingEndDate] < 0){
        // white tenting
        return interval.night ? 2 : 1;
    }else{
        //p checks or tenting over
        return 0;
    }

}
-(void)createIntervalDataArraysUNC
{
    
    
    self.intervalDataByOverallRow = [[NSMutableArray alloc]init];
    self.intervalDataBySection = [[NSMutableDictionary alloc]init];
    
    NSDate *currentIntervalStartDate = [self.startDate copy];
    
    //Initialize first section
    NSString *sectionHeader = [Constants formatDate:currentIntervalStartDate withStyle:NSDateFormatterShortStyle];
    NSDate *sectionDate = [currentIntervalStartDate copy];
    NSUInteger sectionNumber = 0;
    NSUInteger intervalStartIndex = 0;
    
    //Initialize first interval
    NSArray *array = [self availableAndAssignedPersonsForOverallInterval:0];
    NSMutableArray *availablePersons = array[0];
    NSMutableArray *assignedPersons = array[1];
    NSDictionary *endDateAndNight = [self intervalEndDateForIntervalStartDateUNC:currentIntervalStartDate]; //unc
    NSDate *currentIntervalEndDate = endDateAndNight[@"endDate"];
    BOOL night = [endDateAndNight[@"night"] boolValue];
    Interval *currentInterval = [[Interval alloc]initWithStartDate:currentIntervalStartDate endDate:currentIntervalEndDate section:0 availablePersons:availablePersons assignedPersons:assignedPersons];
    currentInterval.night = night;
    currentInterval.requiredPersons = [self requiredPersonsForUNCInterval:currentInterval];//unc
    [self.intervalDataByOverallRow addObject:currentInterval];
    int numIntervals = 1; //save as interval index
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *previousIntervalStartDate = currentIntervalStartDate;
    NSDateComponents *dateComponentsPrevious;
    NSDateComponents *dateComponentsCurrent;
    while ([currentIntervalEndDate timeIntervalSinceDate:self.endDate] < 0) {
        // Check if Next Section
        dateComponentsPrevious = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:previousIntervalStartDate];
        dateComponentsCurrent = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:currentIntervalStartDate];
        
        if(dateComponentsPrevious.day != dateComponentsCurrent.day) { // New day = new section
            
            //if([currentIntervalStartDate )//if(night){
            //new section
            //Add current section data to dict and initialize new section
            NSMutableDictionary *sectionData = [self sectionDictForDay:sectionDate sectionHeader:sectionHeader intervalStartIndex:intervalStartIndex intervalEndIndex:numIntervals - 1];
            [self.intervalDataBySection setObject:sectionData forKey:[NSNumber numberWithInteger:sectionNumber]]; //why not just use an array where sectioNumber is the index?
            
            //Initialize next section
            sectionHeader = [Constants formatDate:currentIntervalStartDate withStyle:NSDateFormatterShortStyle];
            sectionDate = [currentIntervalStartDate copy];
            intervalStartIndex = numIntervals - 1;
            sectionNumber++;
            
        }
        
        // Create Next Interval
        NSArray *array = [self availableAndAssignedPersonsForOverallInterval:numIntervals];
        NSMutableArray *availablePersons = array[0];
        NSMutableArray *assignedPersons = array[1];
        previousIntervalStartDate = currentIntervalStartDate;
        currentIntervalStartDate = currentIntervalEndDate;
        endDateAndNight = [self intervalEndDateForIntervalStartDateUNC:currentIntervalStartDate];//unc
        currentIntervalEndDate = endDateAndNight[@"endDate"];
        night = [endDateAndNight[@"night"] boolValue];
        Interval *currentInterval = [[Interval alloc]initWithStartDate:currentIntervalStartDate endDate:currentIntervalEndDate section:0 availablePersons:availablePersons assignedPersons:assignedPersons];
        currentInterval.night = night;
        currentInterval.requiredPersons = [self requiredPersonsForUNCInterval:currentInterval]; //unc
        [self.intervalDataByOverallRow addObject:currentInterval];
        numIntervals++;
    }
    //Add last section data to dict
    NSMutableDictionary *sectionData = [self sectionDictForDay:sectionDate sectionHeader:sectionHeader intervalStartIndex:intervalStartIndex intervalEndIndex:numIntervals];
    [self.intervalDataBySection setObject:sectionData forKey:[NSNumber numberWithInteger:sectionNumber]]; //why not just use an array where sectioNumber is the index?
    
    self.numIntervals = numIntervals;

    

}
-(void)createIntervalDataArrays
{
    if([@[@"UNC", @"University of North Carolina", @"North Carolina"] containsObject:self.homeGame.opponentName]){        [self createIntervalDataArraysUNC];
        return;
    }
    
    self.intervalDataByOverallRow = [[NSMutableArray alloc]init];
    self.intervalDataBySection = [[NSMutableDictionary alloc]init];

    NSDate *currentIntervalStartDate = [self.startDate copy];

    //Initialize first section
    NSString *sectionHeader = [Constants formatDate:currentIntervalStartDate withStyle:NSDateFormatterShortStyle];
    NSDate *sectionDate = [currentIntervalStartDate copy];
    NSUInteger sectionNumber = 0;
    NSUInteger intervalStartIndex = 0;
    
    //Initialize first interval
    NSArray *array = [self availableAndAssignedPersonsForOverallInterval:0];
    NSMutableArray *availablePersons = array[0];
    NSMutableArray *assignedPersons = array[1];
    NSDictionary *endDateAndNight = [self intervalEndDateForIntervalStartDate:currentIntervalStartDate];
    NSDate *currentIntervalEndDate = endDateAndNight[@"endDate"];
    BOOL night = [endDateAndNight[@"night"] boolValue];
    Interval *currentInterval = [[Interval alloc]initWithStartDate:currentIntervalStartDate endDate:currentIntervalEndDate section:0 availablePersons:availablePersons assignedPersons:assignedPersons];
    currentInterval.night = night;
    currentInterval.requiredPersons = self.requiredPersonsPerInterval;
    [self.intervalDataByOverallRow addObject:currentInterval];
    int numIntervals = 1; //save as interval index
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *previousIntervalStartDate = currentIntervalStartDate;
    NSDateComponents *dateComponentsPrevious;
    NSDateComponents *dateComponentsCurrent;
    while ([currentIntervalEndDate timeIntervalSinceDate:self.endDate] < 0) {
        // Check if Next Section
        dateComponentsPrevious = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:previousIntervalStartDate];
        dateComponentsCurrent = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:currentIntervalStartDate];
        
        if(dateComponentsPrevious.day != dateComponentsCurrent.day) { // New day = new section

        //if([currentIntervalStartDate )//if(night){
            //new section
            //Add current section data to dict and initialize new section
            NSMutableDictionary *sectionData = [self sectionDictForDay:sectionDate sectionHeader:sectionHeader intervalStartIndex:intervalStartIndex intervalEndIndex:numIntervals - 1];
            [self.intervalDataBySection setObject:sectionData forKey:[NSNumber numberWithInteger:sectionNumber]]; //why not just use an array where sectioNumber is the index?
            
            //Initialize next section
            sectionHeader = [Constants formatDate:currentIntervalStartDate withStyle:NSDateFormatterShortStyle];
            sectionDate = [currentIntervalStartDate copy];
            intervalStartIndex = numIntervals - 1;
            sectionNumber++;

        }
        
        // Create Next Interval
        NSArray *array = [self availableAndAssignedPersonsForOverallInterval:numIntervals];
        NSMutableArray *availablePersons = array[0];
        NSMutableArray *assignedPersons = array[1];
        previousIntervalStartDate = currentIntervalStartDate;
        currentIntervalStartDate = currentIntervalEndDate;
        endDateAndNight = [self intervalEndDateForIntervalStartDate:currentIntervalStartDate];
        currentIntervalEndDate = endDateAndNight[@"endDate"];
        night = [endDateAndNight[@"night"] boolValue];
        Interval *currentInterval = [[Interval alloc]initWithStartDate:currentIntervalStartDate endDate:currentIntervalEndDate section:0 availablePersons:availablePersons assignedPersons:assignedPersons];
        currentInterval.night = night;
        currentInterval.requiredPersons = self.requiredPersonsPerInterval;
        [self.intervalDataByOverallRow addObject:currentInterval];
        numIntervals++;
    }
    //Add last section data to dict
    NSMutableDictionary *sectionData = [self sectionDictForDay:sectionDate sectionHeader:sectionHeader intervalStartIndex:intervalStartIndex intervalEndIndex:numIntervals];
    [self.intervalDataBySection setObject:sectionData forKey:[NSNumber numberWithInteger:sectionNumber]]; //why not just use an array where sectioNumber is the index?

    self.numIntervals = numIntervals;
    
    
    
}

-(void)createIntervalDataArraysOld
{
    
    NSMutableArray *intervalDataByOverallRow = [[NSMutableArray alloc]init];
    NSMutableDictionary *intervalDataBySection = [[NSMutableDictionary alloc]init];
    
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
    
    for(int i = 0; i<self.numIntervals;i++){
        dateComponentsPrevious = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:previousStartInterval];
        dateComponentsCurrent = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:currentStartInterval];
        
        if(dateComponentsPrevious.day != dateComponentsCurrent.day) { // New day = new section
            
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
        
        NSArray *array = [self availableAndAssignedPersonsForOverallInterval:i];
        NSMutableArray *availablePersons = array[0];
        NSMutableArray *assignedPersons = array[1];
        Interval *interval = [[Interval alloc]initWithStartDate:currentStartInterval endDate:currentEndInterval section:sectionNumber availablePersons:availablePersons assignedPersons:assignedPersons];
        interval.requiredPersons = self.requiredPersonsPerInterval;
        [intervalDataByOverallRow addObject:interval];
        [sectionIntervals addObject:interval];
        
        previousStartInterval = currentStartInterval;
        currentStartInterval = currentEndInterval;
        currentEndInterval = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:currentStartInterval];
        NSTimeInterval timeUntilEnd = [self.endDate timeIntervalSinceDate:currentEndInterval];
        
        
        if(timeUntilEnd <= 0 ){
            NSArray *array = [self availableAndAssignedPersonsForOverallInterval:i];
            NSMutableArray *availablePersons = array[0];
            NSMutableArray *assignedPersons = array[1];
            Interval *interval = [[Interval alloc]initWithStartDate:currentStartInterval endDate:self.endDate section:sectionNumber availablePersons:availablePersons assignedPersons:assignedPersons];
            interval.requiredPersons = self.requiredPersonsPerInterval;
            [intervalDataByOverallRow addObject:interval];
            [sectionIntervals addObject:interval];
            
            NSMutableDictionary *sectionData = [self sectionDictForDay:sectionDate sectionHeader:sectionHeader intervalStartIndex:intervalStartIndex intervalEndIndex:i+1];
            
            [intervalDataBySection setObject:sectionData forKey:[NSNumber numberWithInteger:sectionNumber]];
            
        }
        
    }
    
    self.intervalDataBySection = [intervalDataBySection copy];
    self.intervalDataByOverallRow = [intervalDataByOverallRow copy];
    
}

-(NSArray *)availableAndAssignedPersonsForOverallInterval:(NSUInteger)index
{
    NSMutableArray *availablePersons = [[NSMutableArray alloc]init];
    NSMutableArray *assignedPersons = [[NSMutableArray alloc]init];

    for(int i = 0; i<self.personsArray.count;i++){
        Person *person = (Person *)self.personsArray[i];
        NSUInteger availablity = [person.assignmentsArray[index] integerValue];
        if(availablity > 0){
            if(availablity == 2){
                [assignedPersons addObject:person];
            }
            [availablePersons addObject:person];
        }
    }
    return @[availablePersons, assignedPersons];
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

#pragma mark - Stats
-(NSUInteger)numPeople
{
    return self.personsArray.count;
}
-(void)calculateNumIntervalsEachPersonIsAvailableAndAssigned
{
    for(int r = 0;r<[self numPeople];r++){
        int assignSums = 0;
        int availSums = 0;
        Person *person = self.personsArray[r];
        for(int c = 0; c<self.numIntervals;c++){
            
            if([person.assignmentsArray[c] integerValue]== 2){
                assignSums += 1;
                availSums += 1;
           }else if ([person.assignmentsArray[c] integerValue]== 1){
                availSums += 1;
            }
        }
        self.numIntervalsEachPersonIsAvailable[r] = [NSNumber numberWithInteger:availSums];
        self.numIntervalsEachPersonIsAssigned[r] = [NSNumber numberWithInteger:assignSums];
        
    }
}

-(void)calculateNumPeopleAvailableAndAssignedInEachInterval
{
    for(int c = 0; c<self.numIntervals;c++){
        int assignSums = 0;
        int availSums = 0;
        for(int r = 0;r<[self numPeople];r++){
            Person *person = self.personsArray[r];
            if([person.assignmentsArray[c] integerValue]== 2){
                assignSums += 1;
                availSums += 1;
            }else if ([person.assignmentsArray[c] integerValue]== 1){
                availSums += 1;
            }
        }
        self.numPeopleAvailableInEachInterval[c] = [NSNumber numberWithInteger:availSums];
        self.numPeopleAssignedInEachInterval[c] = [NSNumber numberWithInteger:assignSums];
        
    }
}

//interval index is overall index
-(NSUInteger)numPeopleAssignedInIntervalIndex:(NSUInteger)intervalIndex
{
    NSUInteger numPeopleAssigned = 0;
    for(int i = 0; i < self.numPeople; i++){
        Person *person = self.personsArray[i];
        if([person.assignmentsArray[intervalIndex] integerValue] == 2){
            numPeopleAssigned++;
        }
    }
    
    return numPeopleAssigned;
}
-(NSUInteger)numPeopleAvailableInIntervalIndex:(NSUInteger)intervalIndex
{
    NSUInteger numPeopleAvailable = 0;
    for(int i = 0; i < self.numPeople; i++){
        Person *person = self.personsArray[i];
        NSUInteger status =[person.assignmentsArray[intervalIndex] integerValue];
        if(status == 1 | status == 2){
            numPeopleAvailable++;
        }
    }
    
    return numPeopleAvailable;
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
    if (![(id)[self groupName] isEqual:[aSchedule groupName]])
        return NO;
    if (!([self startDate] == [aSchedule startDate]))
        return NO;
    if (![(id)[self endDate] isEqual:[aSchedule endDate]])
        return NO;
    //TODO: add more
    // NSLog(@"Test equality");
    return YES;
}


@end
