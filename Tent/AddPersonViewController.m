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

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.enterNameTextField];
    self.doneButton.enabled = NO;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.enterNameTextField];
}
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender==self.doneButton){
        PickPersonTableViewController *pptvc = [segue destinationViewController];
        pptvc.addPersonName = self.enterNameTextField.text;
    }
}
@end
