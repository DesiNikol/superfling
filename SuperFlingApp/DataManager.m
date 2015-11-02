//
//  DataManager.m
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import "DataManager.h"
#import "AFNetworking/AFNetworking.h"
#import "FlingObject.h"

#define kDataURL @"http://challenge.superfling.com/"
#define kImagesURL @"http://challenge.superfling.com/photos/"

@implementation DataManager

+(DataManager *)sharedObject
{
    static DataManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

/* Loading all contect from the server via AFNetworking */

-(void)loadContent
{
    self.superFlings = [[NSMutableArray alloc] init];

    
    NSURL *baseURL = [NSURL URLWithString:kDataURL];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];

    NSMutableURLRequest *request = [client  requestWithMethod:@"GET" path:nil parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         
         NSError *e = nil;
         NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingAllowFragments error: &e];
         
         for(NSDictionary *dict in jsonArray)
         {
             NSLog(@"result %@", dict.description);
             FlingObject *fo = [[FlingObject alloc] init];
             fo._id = [[dict objectForKey:@"ID"] intValue];
             fo.imageId = [[dict objectForKey:@"ImageID"] intValue];
             fo.userId = [[dict objectForKey:@"UserID"] intValue];
             fo.title = [dict objectForKey:@"Title"];
             fo.userName = [dict objectForKey:@"UserName"];
             
             //[self loadFlingImage:fo];
             
             [[DataManager sharedObject].superFlings addObject:fo];
             
         }
         
         [self cacheData];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:@"DataLoaded" object:nil];
         
         
      }failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
         
     }];
    [operation start];
}

-(void)loadFlingImage:(FlingObject*)flingObject
{
    NSString *url = [NSString stringWithFormat:@"%@%d", kImagesURL, flingObject.imageId];
    NSLog(@"url %@", url);
    NSURL *baseURL = [NSURL URLWithString:url];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];
    
    NSMutableURLRequest *request = [client  requestWithMethod:@"GET" path:nil parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         
         NSError *e = nil;
         NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingAllowFragments error: &e];
         
         
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         
     }];
    [operation start];
}

/* Core Data */

-(void)cacheData
{
    
}

@end
