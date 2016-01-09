//
//  HomeGame.m
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "HomeGame.h"

@implementation HomeGame

-(instancetype)initWithOpponentName:(NSString *)name gameTime:(NSDate *)date isExhibition:(BOOL)isExhibition isConferenceGame:(BOOL)isConferenceGame currentSeason:(BOOL)currentSeason parseObjectID:(NSString *)parseObjectID
{
    self = [super init];
    if(self){
        self.opponentName = name;
        self.gameTime = date;
        self.isExhibition = isExhibition;
        self.isConferenceGame = isConferenceGame;
        self.currentSeason = currentSeason;
        self.parseObjectID = parseObjectID;
    }
    return self;
}

// UNC
/* commented out because it's a parse property now
-(BOOL)isUNC
{
    return [@[@"UNC", @"University of North Carolina", @"North Carolina"] containsObject:self.opponentName];
}
 */


// Don't think I need coding anymore because I'm not saving to User Defaults
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.opponentName = [aDecoder decodeObjectForKey:@"opponent"];
        self.gameTime = [aDecoder decodeObjectForKey:@"gameTime"];
        self.isExhibition = [[aDecoder decodeObjectForKey:@"isExhibition"]boolValue];
        self.isConferenceGame = [[aDecoder decodeObjectForKey:@"isConferenceGame"]boolValue];
        self.parseObjectID = [aDecoder decodeObjectForKey:@"objectId"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.opponentName forKey:@"opponent"];
    [aCoder encodeObject:self.gameTime forKey:@"gameTime"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isExhibition] forKey:@"isExhibition"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isConferenceGame] forKey:@"isConferenceGame"];
    [aCoder encodeObject:self.parseObjectID forKey:@"objectId"];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToHomeGame:(HomeGame *)other]; // class-specific
}

-(BOOL)isEqualToHomeGame:(HomeGame *)other
{
    BOOL opponentName = [self.opponentName isEqualToString:other.opponentName];
    BOOL gameTime = [self.gameTime isEqual:other.gameTime];
    BOOL isExhibition = self.isExhibition == other.isExhibition;
    BOOL isConferenceGame = self.isConferenceGame == other.isConferenceGame;
    BOOL objectId = self.parseObjectID == other.parseObjectID;
    
    return opponentName & gameTime & isExhibition & isConferenceGame & objectId;
}

//TODO: Apple says I need to also implement hash function. But it also says the hash value shouldn't change while the object is in the collection. But maybe it will change? I guess if I always use arrays and don't check equality on the mutable arrays than I'll be fine

@end
