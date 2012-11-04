//
//  DetailPageControl.m
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-3.
//
//

#import "DetailPageViewController.h"
static NSUInteger kNumberOfPages = 2;
@interface DetailPageViewController ()

@end
@implementation DetailPageViewController
@synthesize scrollView=_scollView;
@synthesize pageControl=_pageControl;
@synthesize viewControllers=_viewControllers;
@synthesize detailItem=_detailItem;
@synthesize posterName=_posterName;
@synthesize request=_request;

- (void)dealloc
{
    [_detailItem release];
    [self.scrollView release];
    [self.request clearDelegatesAndCancel];
    [self.request release];
    [super dealloc];
}
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
    }
}
//-(void)requestFinished:(ASIHTTPRequest *) ASIrequest
//{
//    
//}
-(void)requestFinished:(ASIFormDataRequest *) request{
    if (request.tag == 1) {
        NSError *error = [request error];
        if (!error) {
            NSData *img = [request responseData];
            NSString *imgFile = [ImageController getPathToImage: self.posterName];
            [img writeToFile: imgFile atomically: NO];
            
            //设置图片
            NSString *posterPathToFile = [ImageController getPathToImage:self.posterName];
            [[self.viewControllers objectAtIndex:0] setPoster:posterPathToFile];
        }
    }else if (request.tag ==2){
        NSString *response = [request responseString];
        
        NSDictionary *res = (NSDictionary *)[response objectFromJSONString];
        //更新评论列表
        if ([[res objectForKey:@"status"] isEqualToString:@"success"]) {
            NSArray * commentList = [res objectForKey:@"data"];
            for (NSInteger i=0; i< [commentList count]; i++) {
                [SQLite insertComment:[commentList objectAtIndex:i]];
                //[ImageController request4img:(NSString *)[[news objectAtIndex:i] objectForKey: @"image_name"]];
            }
            
            CommentListViewController *controller = [self.viewControllers objectAtIndex:1];
            controller.commentList  = [SQLite selectComments:[[self.detailItem objectForKey:@"id"]intValue]];
            [controller.tableView reloadData];
            [controller caculateStar];
            
        }
    }
}
- (void)viewDidLoad{
    // a page is the width of the scroll view
    //self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320*kNumberOfPages, self.scrollView.frame.size.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*kNumberOfPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;

    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
    
    self.viewControllers = [[NSMutableArray alloc]init];
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}
- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
   
    if (page == 0) {
        DetailViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Detail"];
        [controller setDetailItem:_detailItem];
        CGRect frame = controller.view.frame;
        frame.origin.x = self.scrollView.frame.size.width * page;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
        [self.viewControllers addObject:controller];
        [self request4poster];
    }else if (page == 1){
        CommentListViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentList"];
        [controller setDetailItem:_detailItem];
        CGRect frame = controller.view.frame;
        frame.origin.x = self.scrollView.frame.size.width * page;
        controller.view.frame = frame;
        
        [self.viewControllers addObject:controller];
        UITableView *commentTV = (UITableView *)[controller.view viewWithTag:5];
        [commentTV setDelegate:self];
        [commentTV setDataSource:self];
        [self.scrollView addSubview:controller.view];
        [self request4commentList];
//        //下面是测试代码
//        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"mousefrom",@"from_name",@"评论comment",@"comment",[NSNumber numberWithInt:5],@"star",[NSNumber numberWithInt:203],@"show_id", nil];
//        [SQLite insertComment:dic];
//        controller.commentList  = [SQLite selectComments:[[self.detailItem objectForKey:@"id"]intValue]];
//        [controller.tableView reloadData];
//        [controller caculateStar];
//        //测试代码完了
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //[self loadScrollViewWithPage:page - 1];
    //[self loadScrollViewWithPage:page];
    //[self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}
- (void)request4poster
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {        
        //请求大图片
        
        self.posterName = [self.detailItem objectForKey:@"poster_name"];
        NSString *imgPathToFile = [ImageController getPathToImage:self.posterName];
        if([[NSFileManager defaultManager] fileExistsAtPath:imgPathToFile]){
            [[self.viewControllers objectAtIndex:0] setPoster:imgPathToFile];
        }else{
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@",@"http://shownews-poster.stor.sinaapp.com/",self.posterName];
            NSURL *url = [NSURL URLWithString:urlStr];
            self.request = [ASIHTTPRequest requestWithURL:url];
            self.request.tag = 1;
            [self.request setDelegate:self];
            [self.request startAsynchronous];
        }
        
        
    }
}

-(void) request4commentList{
    //请求评论列表
    
    NSString *url = @"http://shownews.sinaapp.com/commentList.php";
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    request.tag = 2;
    NSInteger comment_start_id = [SQLite selectLatestCommentId];
    [request addPostValue:[NSString stringWithFormat:@"%d",[[self.detailItem objectForKey:@"id"]intValue]] forKey:@"show_id"];//当前用户Id
    [request addPostValue:[NSString stringWithFormat:@"%d",comment_start_id] forKey:@"comment_start_id"];
    [request startAsynchronous];
    [request release];
}

#pragma mark - Table View
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
    NSLog(@"回复他");
    //    [calendarTableViewDelegate showDetail:[self.showList objectAtIndex: indexPath.row]];
    //
    //    //置为已读
    //    NSDictionary *show = [self.showList objectAtIndex:indexPath.row];
    //    [SQLite updateRead:[[show objectForKey:@"id"]intValue]];
    //    //置为灰色
    //
    //    UITableViewCell *cell = [tv cellForRowAtIndexPath:indexPath];
    //    [cell.textLabel setTextColor:[UIColor grayColor]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[self.viewControllers objectAtIndex:1] getCommentList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = @"Comment";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *comment = [[[self.viewControllers objectAtIndex:1] getCommentList] objectAtIndex:indexPath.row];
    //设置用户
    UILabel *userLable = (UILabel *)[cell.contentView viewWithTag:5];
    
    [userLable setText : [(NSString *) [comment objectForKey:@"from_name"] stringByAppendingString:@":"]];
    //设置评论
    UILabel *commentLable = (UILabel *)[cell.contentView viewWithTag:6];
    [commentLable setText : [comment objectForKey:@"comment"]];
    
    //tag=14-18 计算星星
    int star = [[comment objectForKey:@"star"] intValue];
    
    //实心星星
    for (int i = 0; i<star; i++) {
        UIImageView *starImg = (UIImageView *)[cell.contentView viewWithTag:(14 + i)];
        [starImg setImage:[UIImage imageNamed:@"star_full.png"]];
    }
    
    //空心星星
    for (int i = star; i<5; i++) {
        UIImageView *starImg = (UIImageView *)[cell.contentView viewWithTag:(14 + i)];
        [starImg setImage:[UIImage imageNamed:@"star_empty.png"]];
    }
    
	
	return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CreateComment"]) {
        [[segue destinationViewController] setDetailItem:self.detailItem];
    }
}
- (IBAction)changePage:(id)sender{
    int page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}
// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

@end
