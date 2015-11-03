//
//  CustomTableViewCell.h
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property(nonatomic, retain)IBOutlet UIImageView *image;
@property(nonatomic, retain)IBOutlet UIView *activityView;
@property(nonatomic, retain)IBOutlet UILabel *title;
@property(nonatomic, retain)IBOutlet UILabel *flingDescription;

@end
