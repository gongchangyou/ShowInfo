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
    
    NSString *imgPathToFile = [ImageController getPathToImage:imageFile];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPathToFile];
    [imgView setImage:img];
    
    //tag=14-18 计算星星
    int avg_star = 0;
    for (NSDictionary *comment in self.commentList) {
        int star = [[comment objectForKey:@"star"] intValue];
        
        if (star) {
            avg_star += star ;
        }

    }
    if ([self.commentList count]) {
        avg_star /= [self.commentList count];
    }
    
    
    //实心星星
    for (int i = 0; i<avg_star; i++) {
        UIImageView *starImg = (UIImageView *)[contentView viewWithTag:(14 + i)];
        [starImg setImage:[UIImage imageNamed:@"star_full.png"]];
    }
    
    //空心星星
    for (int i = avg_star; i<5; i++) {
        UIImageView *starImg = (UIImageView *)[contentView viewWithTag:(14 + i)];
        [starImg setImage:[UIImage imageNamed:@"star_empty.png"]];
    }
    
    
    //添加comment tableView
    //CalendarTableView *modalPanel = [[[CalendarTableView alloc] initWithFrame:self.view.bounds title:@"2012-10-03" ] autorelease];
     UITableView *commentTV = (UITableView *)[self.view viewWithTag:5];
     [commentTV setDelegate:self];
     [commentTV setDataSource:self];
    //modalPanel.calendarTableViewDelegate = self;
    
	// Do any additional setup after loading the view.
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
	return [self.commentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = @"Comment";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *comment = [self.commentList objectAtIndex:indexPath.row];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
