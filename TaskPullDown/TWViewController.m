//
//  TWViewController.m
//  TaskPullDown
//
//  Created by Tim Woo on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TWViewController.h"
#import "TWTableViewEditorCell.h"

@interface TWViewController ()

@property (nonatomic, retain) NSMutableArray *tasks;

@property (nonatomic, retain) UIView *keyboardShadow;
@property (strong, nonatomic) IBOutlet UIView *shadow;

@property (nonatomic) BOOL canRelease;
@property (nonatomic) BOOL isNewTask;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

@end

@implementation TWViewController
@synthesize tapGesture;
@synthesize shadow;
@synthesize tableView, tasks, canRelease, keyboardShadow, isNewTask;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tasks = [[NSMutableArray alloc] initWithObjects:@"", @"Pull down to create new tasks!", @"Go crazy", nil];
    self.canRelease = NO;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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
    [self.tasks removeObjectAtIndex:1];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] 
                          withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self hideShadow];
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
    
    if (indexPath.row == 0) {
//        tcell.hidden = YES;
    }
    
    tcell.textField.delegate = self;
    tcell.textField.text = [self.tasks objectAtIndex:indexPath.row];
    tcell.selectedBackgroundView = tcell.selectedBkgView;
    
    return tcell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (indexPath.row == 0 && self.isNewTask) {
        NSLog(@"display HIDE: %u", indexPath.row);

//        ((TWTableViewEditorCell *)cell).hidden = YES;
    }
    if (indexPath.row == 0 && !self.isNewTask) {
        NSLog(@"display SHOW: %u", indexPath.row);
//        ((TWTableViewEditorCell *)cell).hidden = NO;
    }
    if (indexPath.row == 1 && self.isNewTask) {
        [((TWTableViewEditorCell *)cell).textField becomeFirstResponder];
        ((TWTableViewEditorCell *)cell).overlay.hidden = YES;
        self.isNewTask = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tasks replaceObjectAtIndex:0 withObject:@"Pulldown to create task"];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.tableView.contentOffset.y < 0.0) {
        self.isNewTask = YES;
        // Insert hidden top row
        [self.tasks insertObject:@"" atIndex:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
         // Set text of new task to empty and reload
        [self.tasks replaceObjectAtIndex:1 withObject:@""];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil] 
                              withRowAnimation:UITableViewRowAnimationNone];//        [self.tableView reloadData];
        [self showShadow];
    }
    self.canRelease = NO;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        [self.tasks replaceObjectAtIndex:1 withObject:textField.text];
        [self.tableView endEditing:YES];
        
    }
    else {
        [self.tableView endEditing:YES];
        [self.tasks removeObjectAtIndex:1];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] 
                              withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    // renables overlay so it can be pressed without editing
    ((TWTableViewEditorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).overlay.hidden = NO;
    
    return YES;
}

@end
