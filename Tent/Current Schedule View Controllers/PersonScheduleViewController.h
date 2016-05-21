//
//  PersonScheduleViewController.h
//  Tent
//
//  Created by Jeremy on 1/1/16.
//  Copyright © 2016 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "Schedule.h"
#import "Constants.h"


@interface PersonScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Schedule *schedule;
@property (nonatomic) Person *currentPerson;
@property(nonatomic, strong) NSMutableArray *updatedAvailabilitiesArray;
@property (nonatomic) NSMutableArray *updatedIntervalDataByOverallRowArray;
//have updated interval array too
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL isMe;
@property (nonatomic) BOOL isCreator;
@property (nonatomic) BOOL canEdit;


-(void)scrollToCurrentInterval;
-(void)saveEdits;
@end
