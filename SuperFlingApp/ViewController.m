//
//  ViewController.m
//  SuperFlingApp
//
//  Created by Desi Nikolova on 11/2/15.
//  Copyright © 2015 Desi Nikolova. All rights reserved.
//

#import "ViewController.h"
#import "DataManager.h"
#import "CustomTableViewCell.h"
#import "FlingObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Retrieiving all data from saved objects in core data
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"DataLoaded" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DataManager sharedObject].superFlings.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    FlingObject *fo = [[DataManager sharedObject].superFlings objectAtIndex:indexPath.row];
    cell.title.text = fo.title;
    //cell.activityView.hidden = NO;
    if(fo.image)
    {
        cell.image.image = fo.image;
        cell.activityView.hidden = YES;
        [cell.image setNeedsDisplay];
    }
    
    return cell;
}

-(void)refreshView
{
    //NSLog(@"done! %lu", (unsigned long)[DataManager sharedObject].superFlings.count);
    //
    self.activityView.hidden = YES;
    [self.tableView reloadData];
}

@end
