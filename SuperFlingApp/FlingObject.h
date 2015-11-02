//
//  FlingObject.h
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlingObject : NSObject

@property(nonatomic, assign) int _id;
@property(nonatomic, assign) int imageId;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, assign) int userId;
@property(nonatomic, retain) NSString *userName;
//
@property(nonatomic, retain) UIImage *image;

@end
