//
//  TWViewController.h
//  TaskPullDown
//
//  Created by Tim Woo on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
