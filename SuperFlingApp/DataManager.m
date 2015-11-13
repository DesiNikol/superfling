//
//  DataManager.m
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import "DataManager.h"
#import <AFNetworking/AFNetworking.h>
#import "Fling.h"
#import "AppDelegate.h"
#import "Constants.h"


@implementation DataManager

/*
 
 * Using singleton  for easy access to all methods.
 
 */

+(DataManager *)sharedObject
{
    static DataManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

/* 
 
 * Loading all contect from the server via AFNetworking.
 
 * Parsing the content and storing via NSManagedObject;
 
 * ( First verifying that a fling is not saved in Core Data already. )
 
 */

-(void)loadContent
{
    self.superFlings = [[NSMutableArray alloc] init];
    
    [self loadSavedFlings];//Load all saved Flings
    
    NSURL *baseURL = [NSURL URLWithString:kDataURL];
    AFHTTPSessionManager *client = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];

    [client GET:@"" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *jsonArray = responseObject;
        
         AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
         
         NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
         
         dispatch_queue_t saveQueue = dispatch_queue_create("Save Queue",NULL);
         
         queueIsEmpty = false;
         dispatch_barrier_async (saveQueue, ^{
             queueIsEmpty = true;
         });
         
         [self performSelector:@selector(checkQueue) withObject:nil afterDelay:.1];
         
         for(NSDictionary *dict in jsonArray)
         {
             NSLog(@"result %@", dict.description);
             
             //Check if the fling was already saved - Do not save twice!
             
             int ID = [[dict objectForKey:@"ID"] intValue];
             BOOL isSaved = NO;
             for(Fling *fling in self.superFlings)
             {
                 if(fling.flingId.intValue == ID)
                 {
                     isSaved = YES;
                 }
             }
             
             if(isSaved)
             {
                 continue;
             }
             
             dispatch_async(saveQueue, ^{
                 
                 
                 int imageId = [[dict objectForKey:@"ImageID"] intValue];
                 int userId = [[dict objectForKey:@"UserID"] intValue];
                 NSString *title = [dict objectForKey:@"Title"];
                 NSString *userName = [dict objectForKey:@"UserName"];
                 
                 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Fling" inManagedObjectContext:appDelegate.managedObjectContext];
                 NSManagedObject *newFling = [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
                 
                 [newFling setValue:title forKey:@"title"];
                 [newFling setValue:[NSNumber numberWithInt:ID] forKey:@"flingId"];
                 [newFling setValue:[NSNumber numberWithInt:imageId] forKey:@"imageId"];
                 [newFling setValue:[NSNumber numberWithInt:userId] forKey:@"userId"];
                 [newFling setValue:userName forKey:@"userName"];
                 
                
              });
         }
         
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

/*
 
 * Load ALL stored flings at the start in order to avoid
 
 * duplicate entries when loading server data.
 
 */

-(void)loadSavedFlings
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Fling"];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"flingId" ascending:NO];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    if (error != nil) {
        
        //Deal with failure
        
    }
    else {
        
        //Deal with success
        self.superFlings = [[NSMutableArray alloc] initWithArray:results];
        //
        
    }

}

/* 
 
 * Check if the initial queue for data retrieval is empty
 
 * and load the flings in the main table if so

 */

-(void)checkQueue
{
    
    if(queueIsEmpty)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        NSError *error;
        [managedObjectContext save:&error];
        
        if(error)
        {
            NSLog(@"core data failed");
        }
        
        /* Reload the table view with all new flings */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataLoaded" object:nil];
        
    }else{
        [self performSelector:@selector(checkQueue) withObject:nil afterDelay:.5];
        
    }
}

/*
 
 * Load & store image data for each fling.
 
 */


-(void)loadFlingImageWithID:(int)imageId forFlingWithID:(int)flingID
{
    NSString *path = [NSString stringWithFormat:@"%@%@%d.png", kDataURL, kImagesURLPath, imageId];
    //
    NSURL *baseURL = [NSURL URLWithString:path];
    
    AFHTTPSessionManager *client = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    client.requestSerializer = [AFHTTPRequestSerializer serializer];
    client.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [client GET:@"" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // NSLog(@"Response: %@", responseObject);
        NSData *data = responseObject;
        Fling *superFling = nil;
        for(Fling *fling in self.superFlings)
        {
            if(fling.flingId.intValue == flingID)
            {
                superFling = fling;
                break;
            }
        }
        
        if(superFling)
        {
            superFling.image = data;
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
            NSError *error;
            [managedObjectContext save:&error];
            
            if(error)
            {
                //NSLog(@"core data failed");
            }
            
           [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshImages" object:nil];
            
        }else{
            //NSLog(@"error loading images!! ");
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"failed to load images");
    }];
}



@end
