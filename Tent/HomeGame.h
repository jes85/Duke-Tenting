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
@property (nonatomic) NSDate *gameTime;
@property (nonatomic) BOOL isExhibition;
@property (nonatomic) BOOL isConferenceGame;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSString *parseObjectID;

-(instancetype)initWithOpponentName:(NSString *)name gameTime:(NSDate *)date isExhibition:(BOOL)isExhibition isConferenceGame:(BOOL)isConferenceGame index:(NSUInteger) i parseObjectID: (NSString *)parseObjectID;

// TODO: In V2, maybe add schedulesAssociatedWithThisHomeGame to cache results

@end
