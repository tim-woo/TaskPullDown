//
//  TWViewController.m
//  TaskPullDown
//
//  Created by Tim Woo on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TWViewController.h"
#import "TWTableViewEditorCell.h"

#import <QuartzCore/QuartzCore.h>

@interface TWViewController ()

@property (nonatomic, retain) NSMutableArray *tasks;

@property (nonatomic, retain) UIView *keyboardShadow;
@property (strong, nonatomic) IBOutlet UIView *shadow;

@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isNewTask;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

@end

@implementation TWViewController
@synthesize tapGesture;
@synthesize shadow;
@synthesize tableView, tasks, isDragging, keyboardShadow, isNewTask;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tasks = [[NSMutableArray alloc] initWithObjects:@"", @"Attend Hackathon", @"Climb Mount Everest", @"Try Pulling Down!", nil];
    self.isDragging = NO;
    self.isNewTask = NO;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setShadow:nil];
    [self setTapGesture:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)showShadow {
    self.shadow.hidden = NO;
    self.tapGesture.enabled = YES;
    [UIView animateWithDuration:1.0 delay:0.2 options:0 animations:^{
        [self.shadow setAlpha:0.8];
    } completion:nil];
}

- (void)hideShadow {    
    [UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
        [self.shadow setAlpha:0.0];
    } completion:nil];
    
    self.shadow.hidden = YES;
    self.tapGesture.enabled = NO;
}

- (IBAction)endEditing:(id)sender {
    [self.tableView endEditing:NO];
    [self.tasks removeObjectAtIndex:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] 
                          withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark keyboard notifications

- (void)keyboardWillHide:(NSNotification *)notification {
    [self hideShadow];
}

- (void)keyboardDidHide:(NSNotification *)notification {    
    [self.tasks insertObject:@"" atIndex:0];
    [self.tableView reloadData];
    UIEdgeInsets ins = self.tableView.contentInset;
    self.tableView.contentInset = UIEdgeInsetsMake(-44.0, ins.left, ins.bottom, ins.right);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[self.tasks objectAtIndex:indexPath.row] message:nil delegate:nil cancelButtonTitle:@"Later" otherButtonTitles:@"Okay", nil];
    [alert show];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTableViewEditorCell *tcell = [self.tableView dequeueReusableCellWithIdentifier:@"SWTableViewEditorCell_0"];
    if (!tcell) {
        tcell = [[[NSBundle mainBundle] loadNibNamed:@"TWTableViewEditorCell" owner:self options:nil] objectAtIndex:0];
    }
    
    tcell.textField.delegate = self;
    tcell.textField.text = [self.tasks objectAtIndex:indexPath.row];
    tcell.selectedBackgroundView = tcell.selectedBkgView;
    tcell.layer.anchorPoint = CGPointMake(1, 1);
    
    return tcell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {   
    
    TWTableViewEditorCell *tcell = (TWTableViewEditorCell *)cell;
    
    if (indexPath.row == 0) {
        if (self.isNewTask) {
            NSLog(@"new task");
            
            [tcell.textField becomeFirstResponder];
            tcell.overlay.hidden = YES;
            self.isNewTask = NO;
        }
        else {
            NSLog(@"pulling down hidden row");
            CATransform3D rotation = CATransform3DMakeRotation(-M_PI_2, 1.0, 0, 0);
            CATransform3D trans = CATransform3DTranslate(rotation, 0.0, 0.0, -100.0);
            tcell.layer.transform = trans;
        }
    }

    tcell.releaseLabel.hidden = YES;
    tcell.pullDownLabel.hidden = YES;
}

#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    TWTableViewEditorCell *tcell = (TWTableViewEditorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (self.isDragging) {
        if (self.tableView.contentOffset.y < 0.0) {
            tcell.releaseLabel.hidden = NO;
            tcell.pullDownLabel.hidden = YES;
        }
        else {
            tcell.releaseLabel.hidden = YES;
            tcell.pullDownLabel.hidden = NO;
        }
    }
    
    if (self.isDragging && self.tableView.contentOffset.y < 44.0 && self.tableView.contentOffset.y > 0.0) {
        
        // The rotation is dependent on the tableview's content offset. 
        CGFloat degrees = self.tableView.contentOffset.y * -M_PI_2 / 44.0;
        CATransform3D trans = CATransform3DMakeRotation(degrees, 1.0, 0.0, 0.0);
        trans.m34 = 1.0/-5000.0;
        tcell.layer.transform = trans;
    }
    
    if (self.tableView.contentOffset.y < 0 && !CATransform3DIsIdentity(tcell.layer.transform)) {
        tcell.layer.transform = CATransform3DIdentity;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.tableView.contentOffset.y < 0.0) {
        self.isNewTask = YES;
        
        UIEdgeInsets ins = self.tableView.contentInset;
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, ins.left, ins.bottom, ins.right);
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self showShadow];
    }
    
    TWTableViewEditorCell *tcell = (TWTableViewEditorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    tcell.layer.transform = CATransform3DIdentity;
    
    self.isDragging = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        [self.tasks replaceObjectAtIndex:0 withObject:textField.text];
        [self.tableView endEditing:YES];
    }
    else {
        [self.tableView endEditing:YES];
        [self.tasks removeObjectAtIndex:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] 
                              withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    // renables overlay so it can be pressed without editing
    ((TWTableViewEditorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).overlay.hidden = NO;
    
    return YES;
}

@end
