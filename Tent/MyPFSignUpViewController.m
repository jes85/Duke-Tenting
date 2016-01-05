//
//  MyPFSignUpViewController.m
//  Tent
//
//  Created by Jeremy on 8/16/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "MyPFSignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MyPFSignUpViewController ()


@end

@implementation MyPFSignUpViewController

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
    
    [self.signUpView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:(100.0/255.0) alpha:1.0]];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    label.text = @"DUKE K-VILLE PLANNER";
    label.textColor = [UIColor whiteColor];
    
    [self.signUpView setLogo:label];
    //[self.signUpView setLogo: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Krzyzewskiville"]]];
    
    self.signUpView.additionalField.placeholder = @"Full Name";
    //[self.signUpView.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    

    
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
