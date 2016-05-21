//
//  HomeGame.h
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeGame : NSObject <NSCoding>

@property (nonatomic) NSString *opponentName;
@property (nonatomic) BOOL isUNC;
@property (nonatomic) NSDate *gameTime;
@property (nonatomic) BOOL isExhibition;
@property (nonatomic) BOOL isConferenceGame;
@property (nonatomic) BOOL currentSeason;
@property (nonatomic) NSString *parseObjectID;

// make subclass UNCHomeGame for these properties
@property (nonatomic) NSDate *blackTentingStartDate;
@property (nonatomic) NSDate *blueTentingStartDate;
@property (nonatomic) NSDate *whiteTentingStartDate;
@property (nonatomic) NSDate *uncTentingEndDate;


-(instancetype)initWithOpponentName:(NSString *)name gameTime:(NSDate *)date isExhibition:(BOOL)isExhibition isConferenceGame:(BOOL)isConferenceGame currentSeason:(BOOL)currentSeason parseObjectID: (NSString *)parseObjectID;

// In V2, maybe add schedulesAssociatedWithThisHomeGame to cache results

@end
