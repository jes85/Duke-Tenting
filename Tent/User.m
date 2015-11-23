//
//  User.m
//  Tent
//
//  Created by Jeremy on 11/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype) initWithParseObjectId:(NSString *)objectID name:(NSString *)name email:(NSString *)email
{
    self = [super init];
    if(self){
        self.parseObjectID = objectID;
        self.name = name;
        self.email = email;
    }
    return self;
}
@end
