//
//  TWTableViewEditorCell.h
//  TaskPullDown
//
//  Created by Tim Woo on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWTableViewEditorCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIView *selectedBkgView;
@property (strong, nonatomic) IBOutlet UIView *overlay;

@end
