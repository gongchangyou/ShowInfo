//
//  CreatCommentViewController.m
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-3.
//
//

#import "CreateCommentViewController.h"

@interface CreateCommentViewController ()

@end

@implementation CreateCommentViewController
@synthesize detailItem=_detailItem;
@synthesize commentList=_commentList;
@synthesize nameTextField=_nameTextField;
@synthesize rateView=_rateView;
@synthesize tapRateView=_tapRateView;
@synthesize star=_star;
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
    self.star = 0;
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
    
   // self.textView.layer.backgroundColor = UIColor.grayColor.CGColor;
    self.textView.layer.borderWidth = 1;

    self.tapRateView = [[RSTapRateView alloc] initWithFrame:CGRectMake(0, 0, self.rateView.frame.size.width, 50.f)];
    self.tapRateView.delegate = self;
    
    [self.rateView addSubview:self.tapRateView];

}
#pragma mark -
#pragma mark RSTapRateViewDelegate

- (void)tapDidRateView:(RSTapRateView*)view rating:(NSInteger)rating {
    NSLog(@"Current rating: %i", rating);
    self.star = rating;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}
-(IBAction)textFieldDidBeginEditing:(id)sender
{
    
}
- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_textView release];
    [_rateView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [self setRateView:nil];
    [super viewDidUnload];
}

@end
