//
//  DataManager.m
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import "DataManager.h"
#import "AFNetworking/AFNetworking.h"
#import "Fling.h"
#import "AppDelegate.h"

#define kDataURL @"http://challenge.superfling.com/"
#define kImagesURL @"http://challenge.superfling.com/photos/"

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


-(id)init
{
    self = [super init];
    
    //Initializing the nsoperation queue:
    
    self.queue = [[NSOperationQueue alloc] init];
    
    return self;
}

/* 
 
 * Loading all contect from the server via AFNetworking.
 
 * Parsing the content and storing via NSManagedObject;
 
 */

-(void)loadContent
{
    
    NSURL *baseURL = [NSURL URLWithString:kDataURL];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];

    NSMutableURLRequest *request = [client  requestWithMethod:@"GET" path:nil parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         
         NSError *e = nil;
         NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingAllowFragments error: &e];
         
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
             
             dispatch_async(saveQueue, ^{
                 
                 int ID = [[dict objectForKey:@"ID"] intValue];
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
         
      }failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
         
     }];
    [operation start];
}

-(void)checkQueue
{
    [self performSelector:@selector(checkQueue) withObject:nil afterDelay:.1];
    
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
        
    }
}


-(void)loadFlingImage:(Fling*)flingObject
{
    NSString *url = [NSString stringWithFormat:@"%@%d", kImagesURL, flingObject.imageId.intValue];
    //
    NSURL *baseURL = [NSURL URLWithString:url];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];
    
    NSMutableURLRequest *request = [client  requestWithMethod:@"GET" path:nil parameters:nil];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Response: %@", responseObject);
        flingObject.image = responseObject;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataLoaded" object:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [requestOperation start];
}


@end
