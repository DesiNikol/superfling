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
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    //Once the data is fully retrieved by the DataManger class, the table is refreshed:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"DataLoaded" object:nil];
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
    
    NSError *error = nil;
    
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    if (error != nil) {
        
        //Deal with failure
        
    }
    else {
        
        //Deal with success
        superFlings = [[NSMutableArray alloc] initWithArray:results];
        //
        self.activityView.hidden = YES;
        //
        [self.tableView reloadData];
        
    }
    
}

#pragma mark UITableViewDelegate 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return superFlings.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Fling *fling = [superFlings objectAtIndex:indexPath.row];
    cell.title.text = fling.title;
    //cell.activityView.hidden = NO;
    if(fling.image)
    {
        cell.image.image = [UIImage imageWithData:fling.image];
        cell.activityView.hidden = YES;
        [cell.image setNeedsDisplay];
    }
    
    return cell;
}

#pragma mark -


@end
