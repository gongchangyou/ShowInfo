//
//  MasterPageViewController.m
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-6.
//
//

#import "MasterPageViewController.h"
static NSUInteger iconsPerPage = 6;
@interface MasterPageViewController ()

@end

@implementation MasterPageViewController
@synthesize scrollView=_scrollView;
@synthesize pageControl=_pageControl;
@synthesize viewControllers=_viewControllers;
@synthesize request=_request;
@synthesize categoryList=_categoryList;

- (void)request4news
{
    NSInteger latestCategoryId = [SQLite selectLatestId:@"category"];
    NSInteger latestShowInfoId = [SQLite selectLatestId:@"show_info"];
    NSArray *showIdArray = [SQLite selectNewsWithoutCategory];
    NSString *showId = @"";
    for(NSDictionary *dic in showIdArray){
        int i = [[dic objectForKey:@"id"]intValue];
        if ([showId isEqualToString:@""]) {
            showId = [NSString stringWithFormat:@"%d",i];
        }else{
            showId = [showId stringByAppendingFormat:@",%d",i];
        }
    }
    
    NSString *url = @"http://2.shownews.sinaapp.com/downloadCS.php";
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    request.tag = 0;
    [request addPostValue:[NSString stringWithFormat:@"%d",latestCategoryId] forKey:@"category_start_id"];
    [request addPostValue:showId forKey:@"show_id_str"];
    [request addPostValue:[NSString stringWithFormat:@"%d",latestShowInfoId] forKey:@"show_info_start_id"];
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
            
            //插入category
            NSArray *categoryList = [res objectForKey:@"category"];
            for (NSInteger i=0; i< [categoryList count]; i++) {
                [SQLite insertCategory:[categoryList objectAtIndex:i]];
            }
            
            //更新show_info的categoryId
            NSArray *updateShowList = [res objectForKey:@"update_show_info"];
            for (NSInteger i=0; i< [updateShowList count]; i++) {
                [SQLite updateCategoryId:[updateShowList objectAtIndex:i]];
            }
            BOOL welcomeFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"welcomeFlag"];
            if (!welcomeFlag) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"welcomeFlag"];
            }
        }else {
            NSLog(@"%@",[res objectForKey:@"status"]);
            
            NSString *status = [res objectForKey:@"status"];
            [[[iToast makeText:NSLocalizedString(status, @"")]setGravity:iToastGravityBottom] show];
        }
        [self show];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
    //自己插入category如果没有的话
    NSInteger welcomeFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"welcomeFlag"];
    if (!welcomeFlag) {
        [[[iToast makeText:NSLocalizedString(@"网络连接不上哦~", @"")]setGravity:iToastGravityBottom] show];
    }   
}
- (void)show{
    //整理图标 贴label
    //搜索category的个数 /6 确定有几个page
    self.categoryList = [SQLite selectCategory];
    int kNumberOfPages = ([self.categoryList count] + iconsPerPage - 1)/iconsPerPage;
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*kNumberOfPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
    
    self.viewControllers = [[NSMutableArray alloc]init];
    for (int i=0; i<kNumberOfPages; i++) {
        [self loadScrollViewWithPage:i maxPage:kNumberOfPages];
    }
}

- (void)loadScrollViewWithPage:(int)page maxPage:(int)kNumberOfPages
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    int end = (page+1) * iconsPerPage;
    if (page == kNumberOfPages - 1) {
        //最后一页
        end = [self.categoryList count];
    }
    NSMutableArray *categoryListTmp = [[NSMutableArray alloc]init];
   
    for(int i=page*6; i<end; i++) {
        [categoryListTmp addObject:[self.categoryList objectAtIndex:i]];
    }
    CategoryViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Category"];
    controller.categoryList = categoryListTmp;
    [controller setDelegate:self];
    
    CGRect frame = controller.view.frame;
    frame.origin.x = self.scrollView.frame.size.width * page;
    controller.view.frame = frame;
    [self.scrollView addSubview:controller.view];
    [self.viewControllers addObject:controller];
    [controller release];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{

    if (pageControlUsed)
    {
        return;
    }

    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}
- (void)viewDidLoad{
    // a page is the width of the scroll view
    
    [self request4news];
    [self show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scrollView release];
    [_pageControl release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}
- (IBAction)changePage:(id)sender{
    int page = self.pageControl.currentPage;
	

    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];

    pageControlUsed = YES;
    
}

- (void)turnToMasterView:(UIButton *)sender{
    //NSLog(@"%d",sender.tag);
    [self performSegueWithIdentifier:@"ShowMasterView" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)button
{
    if ([[segue identifier] isEqualToString:@"ShowMasterView"]) {
        
        [(MasterViewController *)[segue destinationViewController] setCategoryId:button.tag];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
