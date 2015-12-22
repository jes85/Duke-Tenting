//
//  AddPersonViewController.m
//  Tent
//
//  Created by Shrek on 8/9/14.
//  Copyright (c) 2014 Jeremy. All rights reserved.
//

#import "AddPersonViewController.h"
#import "PickPersonTableViewController.h"

@interface AddPersonViewController()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (weak, nonatomic) IBOutlet UITextField *enterNameTextField;



@end

@implementation AddPersonViewController

#pragma mark - View Controller Lifecycle
-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.enterNameTextField];
    self.doneButton.enabled = NO;
    [self.enterNameTextField becomeFirstResponder];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.enterNameTextField];
}

#pragma mark - Done Button and Text Field
-(BOOL)shouldEnableDoneButton
{
    BOOL enableDoneButton = NO;
    if(self.enterNameTextField.text!=nil && self.enterNameTextField.text.length>0)
    {
        enableDoneButton = YES;
    }
    return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note
{
    self.doneButton.enabled = [self shouldEnableDoneButton];
}

- (IBAction)textFieldDoneEditing:(id)sender{
    if([self.enterNameTextField isFirstResponder]){
        [self.enterNameTextField resignFirstResponder];
    }
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender==self.doneButton){
        PickPersonTableViewController *pptvc = [segue destinationViewController];
        pptvc.addPersonName = self.enterNameTextField.text;
    }
}


@end
