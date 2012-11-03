//
//  DetailPageControl.m
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-3.
//
//

#import "DetailPageViewController.h"
static NSUInteger kNumberOfPages = 4;
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
    [self.request clearDelegatesAndCancel];
    [self.request release];
    [super dealloc];
}
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        // Update the view.
        //[self configureView];
    }
}
-(void)requestFinished:(ASIHTTPRequest *) ASIrequest
{
    if (ASIrequest.tag == 1) {
        NSError *error = [ASIrequest error];
        if (!error) {
            NSData *img = [ASIrequest responseData];
            NSString *imgFile = [ImageController getPathToImage: self.posterName];
            [img writeToFile: imgFile atomically: NO];
            
            //设置图片
            NSString *posterPathToFile = [ImageController getPathToImage:self.posterName];
            [[self.viewControllers objectAtIndex:0] setPoster:posterPathToFile];
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
        [self configureView];
    }else if (page == 1){
        CommentListViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentList"];
        [controller setDetailItem:_detailItem];
        CGRect frame = controller.view.frame;
        frame.origin.x = self.scrollView.frame.size.width * page;
        controller.view.frame = frame;
        
       // [self.scrollView addSubview:controller.view];
    }
}
- (void)configureView
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
- (IBAction)changePage:(id)sender{
}

@end
