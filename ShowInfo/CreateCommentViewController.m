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
@synthesize scrollView=_scrollView;
@synthesize UUID=_UUID;
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
    self.UUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ShowInfo_UUID"];
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
        [starImg setImage:[UIImage imageNamed:@"Resource/star_full.png"]];
    }
    
    //空心星星
    for (int i = avg_star; i<5; i++) {
        UIImageView *starImg = (UIImageView *)[contentView viewWithTag:(14 + i)];
        [starImg setImage:[UIImage imageNamed:@"Resource/star_empty.png"]];
    }
    
   // self.textView.layer.backgroundColor = UIColor.grayColor.CGColor;
    self.textView.layer.borderWidth = 1;

    self.tapRateView = [[RSTapRateView alloc] initWithFrame:CGRectMake(0, 0, self.rateView.frame.size.width, 50.f)];
    self.tapRateView.delegate = self;
    
    [self.rateView addSubview:self.tapRateView];
    
    NSMutableDictionary *dic = [SQLite selectUser:self.UUID];
    self.nameTextField.text = [dic objectForKey:@"name"];

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
    [scrollView adjustOffsetToIdealIfNeeded];
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
    [_scrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [self setRateView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
- (IBAction)addComment:(id)sender{
    NSString *name = self.nameTextField.text;
    if ([name isEqual:@""]) {
        name = @"游客";
    }
    //保存用户信息
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.UUID,@"UUID",name,@"name", nil];
    [SQLite updateUser:dict];
    
    
    NSString *url = [kDomain stringByAppendingString:@"addComment.php"];
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    request.tag = 0;
    [request addPostValue:self.UUID forKey:@"UUID"];
    [request addPostValue:name forKey:@"name"];
    [request addPostValue:[NSString stringWithFormat:@"%d",self.star] forKey:@"star"];
    [request addPostValue:self.textView.text forKey:@"comment"];
    [request addPostValue:[self.detailItem objectForKey:@"id"] forKey:@"show_id"];
    [request startAsynchronous];
    [request release];
}

-(void)requestFinished:(ASIFormDataRequest *) request
{
    if (request.tag == 0) {
        NSString *response = [request responseString];
        
        NSDictionary *res = (NSDictionary *)[response objectFromJSONString];

        NSString *status = [res objectForKey:@"status"];
        NSString *message = [res objectForKey:@"message"];
        if ([status isEqualToString:@"success"]) {
            [[[iToast makeText:NSLocalizedString(message, @"")]setGravity:iToastGravityBottom] show];            
        }else{
            [[[iToast makeText:NSLocalizedString(message, @"")]setGravity:iToastGravityBottom] show];
        }
    }
}

-(void)requestFailed:(ASIFormDataRequest *) request
{
    if (request.tag == 0) {
        [[[iToast makeText:NSLocalizedString(@"网络连接不上哦~", @"")]setGravity:iToastGravityBottom] show];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
