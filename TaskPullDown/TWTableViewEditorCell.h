//
//  TWTableViewEditorCell.h
//  TaskPullDown
//
//  Created by Tim Woo on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TWTableViewEditorCellDelegate;

@interface TWTableViewEditorCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIView *selectedBkgView;
@property (strong, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) IBOutlet UILabel *releaseLabel;
@property (strong, nonatomic) IBOutlet UILabel *pullDownLabel;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDelete;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic, retain) id<TWTableViewEditorCellDelegate> delegate;
@end

@protocol TWTableViewEditorCellDelegate <NSObject>

- (void)cell:(TWTableViewEditorCell *)cell didSwipeToDelete:(UISwipeGestureRecognizer *)gesture;

@end