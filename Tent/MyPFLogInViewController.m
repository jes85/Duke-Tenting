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

    //[self.logInView setBackgroundColor:[UIColor blueColor]];
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"DukeBlueBG"]]];
    
    UIView *logoView = [[UIView alloc]init];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    label.text = @"DUKE K-VILLE PLANNER";
    label.textColor = [UIColor whiteColor];
    [logoView insertSubview:label atIndex:0];
    
    [self.logInView setLogo:logoView];
    //[self.logInView setLogo: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Krzyzewskiville"]]];
    
    
    // Add login field background
    self.fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginFieldBG.png"]];
    self.fieldsBackgroundTest = [[UIView alloc]init];
    self.fieldsBackgroundTest.backgroundColor = [UIColor whiteColor];
    [self.logInView insertSubview:self.fieldsBackgroundTest atIndex:1];
    
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.logInView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 78.5f)];
    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 235.0f, 250.0f, 50.0f)];
    [self.fieldsBackgroundTest setFrame:CGRectMake(35.0f, 185.0f, 250.0f, 100.0f)];
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
