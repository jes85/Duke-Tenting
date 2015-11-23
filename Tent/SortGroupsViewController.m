//
//  SortGroupsViewController.m
//  Tent
//
//  Created by Jeremy on 10/12/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "SortGroupsViewController.h"
#import "JoinScheduleTableViewController.h"
@interface SortGroupsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property NSArray *dataSource;
@end

@implementation SortGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataSource = @[@"Schedule Name", @"Creator Name", @"Start Date"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return self.dataSource.count;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedRow = indexPath.row;
    UITableViewCell *cell;
    for(int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(i==indexPath.row){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Filters" forIndexPath:indexPath];
    if(indexPath.row == self.selectedRow){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([sender isEqual: self.doneButton]){
        if([segue.destinationViewController isKindOfClass:[JoinScheduleTableViewController class]]){
            JoinScheduleTableViewController *jstvc = segue.destinationViewController;
            jstvc.filterBy = self.selectedRow;
        }
    }
    
}


@end
