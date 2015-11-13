//
//  Fling.h
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface Fling : NSManagedObject

@property(nonatomic, strong) NSNumber *flingId;
@property(nonatomic, strong) NSNumber *imageId;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *userName;
//
@property(nonatomic, retain) NSData *image;

@end
