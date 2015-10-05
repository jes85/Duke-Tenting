//
//  ContainerViewController.m
//  Tent
//
//  Created by Jeremy on 10/5/15.
//  Copyright (c) 2015 Jeremy. All rights reserved.
//

#import "ContainerViewController.h"
#import "Constants.h"

@interface ContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) UIViewController *currentViewController;
@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self displayViewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayViewControllerForSegmentIndex: (NSInteger) index
{
    UIViewController *vc = [self viewControllerForSegmentIndex:index];
    [self addChildViewController:vc];
    vc.view.frame = [self frameForContentController];
    [self.containerView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    self.currentViewController = vc;

}

-(CGRect)frameForContentController
{
    return self.containerView.bounds;
}
- (UIViewController *) viewControllerForSegmentIndex: (NSInteger)index
{
    UIViewController *vc;
    switch (index) {
        case 0:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:kChildViewControllerMe];
            break;
        
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:kChildViewControllerPeople];
            break;
        case 2:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:kChildViewControllerTimeSlots];
            break;
    }
    
    return vc;
}

- (void)cycleFromViewController: (UIViewController*) oldVC
               toViewController: (UIViewController*) newVC {
    
    
    // Prepare the two view controllers for the change.
    [oldVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    
    [self transitionFromViewController:oldVC toViewController:newVC duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        [oldVC.view removeFromSuperview];
        [self.containerView addSubview:newVC.view];
    } completion:^(BOOL finished) {
        newVC.view.frame = [self frameForContentController];
        [oldVC removeFromParentViewController];
        [newVC didMoveToParentViewController:self];
    }];
    
    self.navigationItem.title = newVC.title;
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    UIViewController *newVC = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    
    [self cycleFromViewController:self.currentViewController toViewController:newVC];
    
    self.currentViewController = newVC;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
