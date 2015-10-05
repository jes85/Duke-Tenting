//
//  HomeGame.h
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeGame : NSObject

@property (nonatomic) NSString *opponentName;
@property (nonatomic) NSDate *gameTime;
@property (nonatomic) BOOL isExhibition;
@property (nonatomic) BOOL isConferenceGame;

-(instancetype)initWithOpponentName:(NSString *)name gameTime:(NSDate *)date isExhibition:(BOOL)isExhibition isConferenceGame:(BOOL)isConferenceGame;

@end
