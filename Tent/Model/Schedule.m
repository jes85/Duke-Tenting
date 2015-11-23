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
        [self calculateNumIntervals];
        [self createIntervalDataArrays];
    
    }
    return self;
}

-(void)calculateNumIntervals
{
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceDate:self.startDate];
    NSUInteger minutes = ceil(timeInterval/60);
    NSUInteger numIntervals =  minutes / self.intervalLengthInMinutes;
    self.numIntervals = minutes % self.intervalLengthInMinutes == 0 ? numIntervals : numIntervals + 1;
}

#pragma mark - UI Helpers and Formatting


-(void)createIntervalDataArrays
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

#pragma mark - equality


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
