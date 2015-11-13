//
//  DataManager.h
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject<NSFetchedResultsControllerDelegate>
{
    BOOL __block queueIsEmpty;
}

@property(nonatomic, retain) NSMutableArray *superFlings;

+(DataManager *)sharedObject;
//
-(void)loadContent;
-(void)loadFlingImageWithID:(int)imageId forFlingWithID:(int)flingID;

@end
