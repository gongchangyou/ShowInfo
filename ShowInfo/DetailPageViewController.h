//
//  DetailPageControl.h
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-3.
//
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "CommentListViewController.h"
@interface DetailPageViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSDictionary* detailItem;


@property (retain, nonatomic)NSString * posterName;
@property(retain, nonatomic)ASIHTTPRequest *request;
@property (nonatomic, retain) NSMutableArray *viewControllers;

- (IBAction)changePage:(id)sender;

@end
