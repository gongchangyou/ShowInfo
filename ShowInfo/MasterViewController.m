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
    _refreshHeaderView =nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(_refreshHeaderView ==nil){
        
        EGORefreshTableHeaderView *view =[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
        [view release];
        
    }
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    //读取sqlite数据
    self.newsList = [SQLite selectNews];
    //[self performSelectorInBackground:@selector(request4news) withObject:nil];
    //[self request4news];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
//    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
//    self.navigationItem.rightBarButtonItem = addButton;
}
-(void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading =YES;
    
}
-(void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    
    //读取sqlite数据
    //[self request4news];
    [self performSelectorInBackground:@selector(request4news) withObject:nil];
    
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

-(NSString *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    NSString *last_updated_time = [[NSUserDefaults standardUserDefaults] stringForKey:@"last_updated_time"];
    if (last_updated_time == nil) {
        last_updated_time = [self getDate:[NSDate date]];
        [[NSUserDefaults standardUserDefaults] setValue:last_updated_time forKey:@"last_updated_time"];
    }
    
    return last_updated_time; // should return date data source was last changed
    
}
- (NSString *)getDate:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:date];
    int y = [dd year];
    int m = [dd month];
    int d = [dd day];
    int h = [dd hour];
    int min = [dd minute];
   // int s = [dd second];
    return [NSString stringWithFormat:@"%d年%d月%d日 %02d:%02d",y,m,d,h,min];
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
                [ImageController request4img:(NSString *)[[news objectAtIndex:i] objectForKey: @"image_name"]];
            }
            NSArray * calendar = [res objectForKey:@"calendar"];
            for (NSInteger i=0; i< [calendar count]; i++) {
                [SQLite insertCalendar:[calendar objectAtIndex:i]];
            }
            
            self.newsList  = [SQLite selectNews];
            [self.tableView reloadData];
            
            //记录刷新时间
            NSString *last_updated_time = [self getDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setValue:last_updated_time forKey:@"last_updated_time"];
        }else {
            NSLog(@"%@",[res objectForKey:@"status"]);
            
            NSString *status = [res objectForKey:@"status"];
            [[[iToast makeText:NSLocalizedString(status, @"")]setGravity:iToastGravityCenter] show];
        }
        if (_reloading) {
            _reloading =NO;
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        }
    }
}
-(void)requestFailed:(ASIFormDataRequest *) request
{
    if (request.tag == 0) {
        NSLog(@"request failed");
        if (_reloading) {
            _reloading =NO;
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        }
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView=nil;

    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    //设置title
    UILabel *titleLable = (UILabel *)[cell.contentView viewWithTag:1];
    [titleLable setText : [object objectForKey:@"title"]];
    int read = [[object objectForKey:@"read"] intValue];
    if (read) {
        [titleLable setTextColor:[UIColor grayColor]];
    }else {
        [titleLable setTextColor:[UIColor blackColor]];
    }
    //
    titleLable.lineBreakMode = UILineBreakModeWordWrap;  
    titleLable.numberOfLines = 0;  
    
    //设置时间
    UILabel *timeLable = (UILabel *)[cell.contentView viewWithTag:2];
    [timeLable setText : [object objectForKey:@"show_time"]];
    [timeLable setTextColor:[UIColor grayColor]];
    //设置简介
    UILabel *introLable = (UILabel *)[cell.contentView viewWithTag:3];
    [introLable setText : [object objectForKey:@"introduction"]];
    [introLable setTextColor:[UIColor grayColor]];
    //设置图片
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:4];
    NSString *imageFile = [object objectForKey:@"image_name"];
    
    NSString *imgPathToFile = [ImageController getPathToExistImage:imageFile];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPathToFile];
    [imgView setImage:img];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    //置为已读
    NSDictionary *show = [self.newsList objectAtIndex:indexPath.row];
    [SQLite updateRead:[[show objectForKey:@"id"]intValue]];
    //置为灰色
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    [titleLabel setTextColor:[UIColor grayColor]];
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
