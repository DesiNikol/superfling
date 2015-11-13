//
//  ViewController.m
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

/*
 
 * ViewController class renders a UITableView in order to display the 
 
 * the content laoded by the DataManager class - conforms to 
 
 * UITableViewDelegate and UITableViewDatasource.
 
 
 */

#import "ViewController.h"
#import "DataManager.h"
#import "CustomTableViewCell.h"
#import "Fling.h"
#import <CoreData/NSFetchRequest.h>
#import <CoreData/CoreData.h>
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController

/*
 
 * Initial view set-up:
 
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    //Register for global notifications:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"DataLoaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImages) name:@"RefreshImages" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 
 * Retrieving all flings from core data & reloading the table view
 
 */

-(void)refreshView
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
        [DataManager sharedObject].superFlings = [[NSMutableArray alloc] initWithArray:results];
        //
        self.activityView.hidden = YES;
        //
        [self.tableView reloadData];
        
    }
    
}

/*
 
 * Reloading all table view cells:
 
 */

-(void)refreshImages
{
    [self.tableView reloadData];
}

/*
 
 * Table view configuration and display:
 
 */

#pragma mark UITableViewDelegate 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DataManager sharedObject].superFlings.count;
}

/*
 
 * Rendering custom cells:
 
 */

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Fling *fling = [[DataManager sharedObject].superFlings objectAtIndex:indexPath.row];
    cell.title.text = fling.title;//[NSString stringWithFormat:@"%@ - %d", fling.title, fling.imageId.intValue];
    //
    /* If there is an image - loaded & stored - do not load a 2nd time */
    if(fling.image)
    {
        cell.image.image = [UIImage imageWithData:fling.image];
        cell.activityView.hidden = YES;
        [cell.image setNeedsDisplay];
    }else{
        
        /* Load the image data if there is no image for this fling */
        
        dispatch_queue_t imageQueue = dispatch_queue_create("ImageQueue",NULL);
        dispatch_async(imageQueue, ^{
                
                [[DataManager sharedObject] loadFlingImageWithID:fling.imageId.intValue forFlingWithID:fling.flingId.intValue];
            });
         
    }
    return cell;
}

#pragma mark -


@end
