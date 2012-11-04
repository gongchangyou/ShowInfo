//
//  DetailViewController.m
//  ShowInfo
//
//  Created by penglijun on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize detailItem = _detailItem;
@synthesize introductionTextView = _introductionTextView;
@synthesize detailIntroduction;

- (void)dealloc
{
    [_detailItem release];
    [_introductionTextView release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
    }
}


- (void)setPoster:(NSString *)posterPathToFile
{
    
    UIImage *image = [UIImage imageWithContentsOfFile:posterPathToFile];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(160-image.size.width/2, 10, image.size.width, image.size.height)];
    [imgView setImage:image];
    
    [self.introductionTextView addSubview:imgView];
    int blankRows = image.size.height/17;
    NSString *rows = @"";
    for (int i=0; i<blankRows; i++) {
        rows = [rows stringByAppendingString:@"\n"];
        
    }
    NSString *content = [NSString stringWithFormat:@"%@%@",rows,self.detailIntroduction];
    [self.introductionTextView setText: content];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *show_time = [NSString stringWithFormat:@"%@%@%@",@"演出时间：",[self.detailItem objectForKey:@"show_time"], @"\n"];
    NSString *address = [NSString stringWithFormat:@"%@%@%@",@"演出地点：",[self.detailItem objectForKey:@"address"], @"\n"];
    NSString *price = [NSString stringWithFormat:@"%@%@%@",@"演出票价：",[self.detailItem objectForKey:@"price"], @"\n"];
    NSString *telephone = [NSString stringWithFormat:@"%@%@%@",@"订票热线：",[self.detailItem objectForKey:@"telephone"], @"\n"];
    self.detailIntroduction = [NSString stringWithFormat:@"%@%@%@%@\n%@",show_time,address,price, telephone,[self.detailItem objectForKey:@"introduction"]];
	// Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
  
    self.introductionTextView.text = self.detailIntroduction;
    [self.introductionTextView setEditable:NO];

}

- (void)viewDidUnload
{
    [self setIntroductionTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showCommentList"]) {
        [[segue destinationViewController] setDetailItem:self.detailItem];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
