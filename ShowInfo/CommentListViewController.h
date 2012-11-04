//
//  CommentViewController.h
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-2.
//
//

#import <UIKit/UIKit.h>
#import "SQLite.h"
#import "ASIFormDataRequest.h"
#import "ImageController.h"
#import "CalendarTableView.h"

@interface CommentListViewController : UIViewController
@property (strong, nonatomic) NSDictionary* detailItem;
@property (retain, nonatomic) NSArray * commentList;
-(NSArray *)getCommentList;
-(void)caculateStar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end
