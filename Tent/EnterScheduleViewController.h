//
//  EnterScheduleViewController.h
//  Tent
//
//  Created by Shrek on 8/2/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface EnterScheduleViewController : UIViewController

@property (nonatomic, strong) NSArray *hourIntervals; //for one day 8am-5 pm
@property(nonatomic, strong) NSMutableArray *updatedAvailabilitiesArray;
@property(nonatomic, weak) Person *currentPerson;
@end
