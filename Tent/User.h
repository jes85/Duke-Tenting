//
//  User.h
//  Tent
//
//  Created by Jeremy on 11/17/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

//Might just use PFUser instead

// Init
-(instancetype) initWithParseObjectId:(NSString *)objectID name:(NSString *)name email:(NSString *)email;

@property (nonatomic) NSString *parseObjectID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *email;

@end
