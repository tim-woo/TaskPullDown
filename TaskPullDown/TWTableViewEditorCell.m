//
//  TWTableViewEditorCell.m
//  TaskPullDown
//
//  Created by Tim Woo on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TWTableViewEditorCell.h"

@implementation TWTableViewEditorCell
@synthesize textField;
@synthesize selectedBkgView;
@synthesize overlay;
@synthesize releaseLabel;
@synthesize pullDownLabel;
@synthesize swipeDelete;
@synthesize indexPath;
@synthesize delegate;

- (IBAction)swipeToDelete:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didSwipeToDelete:)]) {
        [self.delegate cell:self didSwipeToDelete:self.swipeDelete];
    }
}
@end


