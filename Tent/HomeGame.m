//
//  HomeGame.m
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "HomeGame.h"

@implementation HomeGame

-(instancetype)initWithOpponentName:(NSString *)name gameTime:(NSDate *)date isExhibition:(BOOL)isExhibition isConferenceGame:(BOOL)isConferenceGame index:(NSUInteger)i parseObjectID:(NSString *)parseObjectID{
    self = [super init];
    if(self){
        self.opponentName = name;
        self.gameTime = date;
        self.isExhibition = isExhibition;
        self.isConferenceGame = isConferenceGame;
        self.index = i;
        self.parseObjectID = parseObjectID;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.opponentName = [aDecoder decodeObjectForKey:@"opponent"];
        self.gameTime = [aDecoder decodeObjectForKey:@"gameTime"];
        self.isExhibition = [[aDecoder decodeObjectForKey:@"isExhibition"]boolValue];
        self.isConferenceGame = [[aDecoder decodeObjectForKey:@"isConferenceGame"]boolValue];
        self.index = [[aDecoder decodeObjectForKey:@"index"] integerValue];
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
    [aCoder encodeObject:[NSNumber numberWithInteger:self.index] forKey:@"index"];
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
    BOOL index = self.index == other.index;
    BOOL objectId = self.parseObjectID == other.parseObjectID;
    
    return opponentName & gameTime & isExhibition & isConferenceGame & index & objectId;
}

//TODO: Apple says I need to also implement hash function. But it also says the hash value shouldn't change while the object is in the collection. But maybe it will change? I guess if I always use arrays and don't check equality on the mutable arrays than I'll be fine

@end
