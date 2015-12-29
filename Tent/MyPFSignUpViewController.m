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
@property(nonatomic) UIImageView *fieldsBackground;
@property(nonatomic) UIView *fieldsBackgroundTest;

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
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%f, %f", self.signUpView.dismissButton.frame.origin.y, self.signUpView.frame.origin.y);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"DukeBlueBG"]]];
    
    UIView *logoView = [[UIView alloc]init];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    label.text = @"DUKE K-VILLE PLANNER";
    label.textColor = [UIColor whiteColor];
    [logoView insertSubview:label atIndex:0];
    
    [self.signUpView setLogo:logoView];
    //[self.signUpView setLogo: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Krzyzewskiville"]]];
    
    
    // Add login field background
    self.fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginFieldBG.png"]];
    self.fieldsBackgroundTest = [[UIView alloc]init];
    self.fieldsBackgroundTest.backgroundColor = [UIColor whiteColor];
    [self.signUpView insertSubview:self.fieldsBackgroundTest atIndex:1];
    
    // Remove text shadow
    
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.additionalField.layer;
    layer.shadowOpacity = 0.0;
    
    // Set field text color
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];

    
    //[self.signUpView.dismissButton setImage:[UIImage imageNamed:@"ExitX"] forState:UIControlStateNormal];
    //[self.signUpView.dismissButton setImage:[UIImage imageNamed:@"ExitXHighlighted"] forState:UIControlStateHighlighted];

    [self.signUpView.dismissButton setTitle:@"x" forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitle:@"x" forState:UIControlStateHighlighted];
    [self.signUpView.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];

    [self.signUpView.dismissButton setImage:nil forState:UIControlStateNormal];

    self.signUpView.additionalField.placeholder = @"Full Name";
}


-(void) viewDidLayoutSubviews //fix to be dependent on platform
{
    [super viewDidLayoutSubviews];
    // Move all fields down on smaller screen sizes
    float yOffset = [UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
    
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    
    [self.signUpView.dismissButton setFrame:CGRectMake(20.0f, 20.0f, 87.5f, 45.5f)];
    [self.signUpView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
    [self.fieldsBackgroundTest setFrame:CGRectMake(35.0f, fieldFrame.origin.y + yOffset, 250.0f, fieldFrame.size.height*4)];
    
    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width - 10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width - 10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                    fieldFrame.origin.y + yOffset,
                                                    fieldFrame.size.width - 10.0f,
                                                    fieldFrame.size.height)];
   
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                    fieldFrame.origin.y + yOffset,
                                                    fieldFrame.size.width - 10.0f,
                                                    fieldFrame.size.height)];
    }
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"%f, %f", self.signUpView.dismissButton.frame.origin.y, self.signUpView.frame.origin.y);

    
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
