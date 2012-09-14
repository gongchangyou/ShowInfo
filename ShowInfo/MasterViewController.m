//
//  MasterViewController.m
//  ShowInfo
//
//  Created by penglijun on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController
@synthesize newsList;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)dealloc
{
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //读取sqlite数据
    
    self.newsList = [SQLite selectNews];
    
    [self request4news];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
//    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
//    self.navigationItem.rightBarButtonItem = addButton;
}


- (void)request4news
{
    NSInteger latestId = [SQLite selectLatestId];
    NSString *url = @"http://shownews.sinaapp.com/downloadNews.php";
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    request.tag = 0;
    [request addPostValue:[NSString stringWithFormat:@"%d",latestId] forKey:@"start_id"];//当前用户Id
    [request startAsynchronous];
    [request release];
}


-(void)requestFinished:(ASIFormDataRequest *) request
{
    if (request.tag == 0) {
        NSString *response = [request responseString];
    
        NSDictionary *res = (NSDictionary *)[response objectFromJSONString];
        if ([[res objectForKey:@"status"] isEqualToString:@"success"]) {
            NSArray * news = [res objectForKey:@"data"];
            for (NSInteger i=0; i< [news count]; i++) {
                [SQLite insertNews:[news objectAtIndex:i]];
            }
            NSArray * calendar = [res objectForKey:@"calendar"];
            for (NSInteger i=0; i< [calendar count]; i++) {
                [SQLite insertCalendar:[calendar objectAtIndex:i]];
            }
            
            self.newsList  = [SQLite selectNews];
            [self.tableView reloadData];
        }else {
            NSLog(@"%@",[res objectForKey:@"status"]);
        }
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSInteger row = indexPath.row;
    NSDictionary *object = [self.newsList objectAtIndex:row];
    cell.textLabel.text = [object objectForKey:@"title"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *news = [self.newsList objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:news];
    }
}

@end
