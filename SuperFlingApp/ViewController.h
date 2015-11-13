//
//  ViewController.h
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *superFlings;
}

@property(nonatomic, retain)IBOutlet UITableView *tableView;
@property(nonatomic, retain)IBOutlet UIView *activityView;

@end

