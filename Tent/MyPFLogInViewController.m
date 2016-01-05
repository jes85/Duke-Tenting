//
//  MyPFLogInViewController.m
//  Tent
//
//  Created by Jeremy on 8/16/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "MyPFLogInViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MyPFLogInViewController ()
@property(nonatomic, strong) UIImageView *fieldsBackground;
@property(nonatomic, strong) UIView *fieldsBackgroundTest;
@end

@implementation MyPFLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.logInView setBackgroundColor:[UIColor blueColor]];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    label.text = @"DUKE K-VILLE PLANNER";
    label.textColor = [UIColor whiteColor];
    
    [self.logInView setLogo:label];
    //[self.logInView setLogo: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Krzyzewskiville"]]];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
