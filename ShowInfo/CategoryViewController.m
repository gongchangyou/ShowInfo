//
//  CategoryViewController.m
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-7.
//
//

#import "CategoryViewController.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController
@synthesize categoryList=_categoryList;
@synthesize delegate;
- (void)viewDidLoad
{
    [super viewDidLoad];
    //贴image
    for (int i=0; i< [self.categoryList count]; i++) {
       
        UIButton *button = [[UIButton alloc]init];
        int categoryId = [[[self.categoryList objectAtIndex:i] objectForKey:@"id"]intValue];
        int width = 70;
        if (i %2) {
            [button setFrame:CGRectMake(190, 60*(i-1), width, width)];
        }else{
            [button setFrame:CGRectMake(60, 60*i, width, width)];
        }
        //查找最新的图片
        NSString * imageFile = [SQLite selectImageName:categoryId];
        //设置图片
        UIImage *img = [ImageController getUIImage:imageFile];
        
        [button setBackgroundImage:img forState:UIControlStateNormal];
        [button addTarget:delegate action:@selector(turnToMasterView:) forControlEvents:UIControlEventTouchDown];
        button.tag = categoryId;
        [self.view addSubview:button];
        //添加label
        NSString *name = [[self.categoryList objectAtIndex:i] objectForKey:@"name"];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        int labelHeight = 20;
        int labelWidth = 70;
        if (i %2) {
            [nameLabel setFrame:CGRectMake(190, 72+60*(i-1), labelWidth, labelHeight)];
        }else{
            [nameLabel setFrame:CGRectMake(60,72+60*i, labelWidth, labelHeight)];
        }
        [nameLabel setText:name];
        [nameLabel setAlpha:0.8];
        [nameLabel setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        nameLabel.textAlignment = UITextAlignmentCenter;
        [self.view addSubview:nameLabel];
        
    }
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
