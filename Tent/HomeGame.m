//
//  HomeGame.m
//  Tent
//
//  Created by Jeremy on 8/27/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "HomeGame.h"

@implementation HomeGame

-(instancetype)initWithOpponentName:(NSString *)name gameTime:(NSDate *)date isExhibition:(BOOL)isExhibition isConferenceGame:(BOOL)isConferenceGame{
    self = [super init];
    if(self){
        self.opponentName = name;
        self.gameTime = date;
        self.isExhibition = isExhibition;
        self.isConferenceGame = isConferenceGame;
    }
    return self;
}

@end
