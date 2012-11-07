//
//  MasterPageViewController.h
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-6.
//
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "SQLite.h"
#import "ImageController.h"
#import "iToast.h"
#import "CategoryViewController.h"
@interface MasterPageViewController : UIViewController<UIScrollViewDelegate>
{
    UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;


@property(retain, nonatomic)ASIHTTPRequest *request;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain)NSArray *categoryList;
- (IBAction)changePage:(id)sender;

@end
