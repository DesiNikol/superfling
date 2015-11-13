//
//  DataManager.h
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
{
    BOOL __block queueIsEmpty;
}

@property(nonatomic, retain) NSOperationQueue *queue;

+(DataManager *)sharedObject;
-(void)loadContent;

@end
