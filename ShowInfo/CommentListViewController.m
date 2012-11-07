//
//  CommentViewController.m
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-2.
//
//

#import "CommentListViewController.h"

@interface CommentListViewController ()

@end

@implementation CommentListViewController
@synthesize detailItem=_detailItem;
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        // Update the view.
        //[self configureView];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //读取sqlite 评论数据
    self.commentList = [[NSArray alloc] init];
    self.commentList = [SQLite selectComments:[[self.detailItem objectForKey: @"id"]intValue]];
    UIView *contentView = [self.view viewWithTag:0];
    
    NSDictionary *object = self.detailItem;
    
    //设置title
    UILabel *titleLable = (UILabel *)[contentView viewWithTag:1];
    [titleLable setText : [object objectForKey:@"title"]];
    //
    titleLable.lineBreakMode = UILineBreakModeWordWrap;
    titleLable.numberOfLines = 0;
    
    //设置时间
    UILabel *timeLable = (UILabel *)[contentView viewWithTag:2];
    [timeLable setText : [object objectForKey:@"show_time"]];
//    //设置简介
//    UILabel *introLable = (UILabel *)[contentView viewWithTag:3];
//    [introLable setText : [object objectForKey:@"introduction"]];
//    [introLable setTextColor:[UIColor grayColor]];
    //设置图片
    UIImageView *imgView = (UIImageView *)[contentView viewWithTag:4];
    NSString *imageFile = [object objectForKey:@"image_name"];
    
    UIImage *img = [ImageController getUIImage:imageFile];
    [imgView setImage:img];
    
    [self caculateStar];
}

-(void)caculateStar{
    UIView *contentView = [self.view viewWithTag:0];
    //tag=14-18 计算星星
    float avg_star = 0;
    for (NSDictionary *comment in self.commentList) {
        int star = [[comment objectForKey:@"star"] intValue];
        
        if (star) {
            avg_star += star ;
        }
        
    }
    if ([self.commentList count]) {
        avg_star /= [self.commentList count];
    }
    
    int star = round(avg_star);
    
    //实心星星
    for (int i = 0; i<star; i++) {
        UIImageView *starImg = (UIImageView *)[contentView viewWithTag:(14 + i)];
        [starImg setImage:[UIImage imageNamed:@"Resource/star_full.png"]];
    }
    
    //空心星星
    for (int i = star; i<5; i++) {
        UIImageView *starImg = (UIImageView *)[contentView viewWithTag:(14 + i)];
        [starImg setImage:[UIImage imageNamed:@"Resource/star_empty.png"]];
    }
}
-(NSArray *)getCommentList{
    return self.commentList;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
