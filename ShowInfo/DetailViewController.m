//
//  DetailViewController.m
//  ShowInfo
//
//  Created by penglijun on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController
@synthesize detailItem = _detailItem;
@synthesize introductionTextView = _introductionTextView;
@synthesize posterName;
@synthesize detailIntroduction;
@synthesize request;
- (void)dealloc
{
    [_detailItem release];
    [_introductionTextView release];
    [request clearDelegatesAndCancel];
    [request release];
    [super dealloc];
}

#pragma mark - Managing the detail item

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
            [self setPoster:posterPathToFile];
        }
    }
}
- (void)setPoster:(NSString *)posterPathToFile
{
    
    UIImage *image = [UIImage imageWithContentsOfFile:posterPathToFile];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(160-image.size.width/2, 10, image.size.width, image.size.height)];
    [imgView setImage:image];
    
    [self.introductionTextView addSubview:imgView];
    int blankRows = image.size.height/16;
    NSString *rows = @"";
    for (int i=0; i<blankRows; i++) {
        rows = [rows stringByAppendingString:@"\n"];
        
    }
    NSString *content = [NSString stringWithFormat:@"%@%@",rows,self.detailIntroduction];
    [self.introductionTextView setText: content];
}
- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {

        //设置介绍
        self.introductionTextView.text = self.detailIntroduction;
        [self.introductionTextView setEditable:NO];
        self.navigationItem.title = [self.detailItem objectForKey:@"title"];
        
        //请求大图片
        
        self.posterName = [self.detailItem objectForKey:@"poster_name"];
        NSString *imgPathToFile = [ImageController getPathToImage:self.posterName];
        if([[NSFileManager defaultManager] fileExistsAtPath:imgPathToFile]){
            [self setPoster:imgPathToFile];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *show_time = [NSString stringWithFormat:@"%@%@%@",@"演出时间：",[self.detailItem objectForKey:@"show_time"], @"\n"];
    NSString *address = [NSString stringWithFormat:@"%@%@%@",@"演出地点：",[self.detailItem objectForKey:@"address"], @"\n"];
    NSString *price = [NSString stringWithFormat:@"%@%@%@",@"演出票价：",[self.detailItem objectForKey:@"price"], @"\n"];
    NSString *telephone = [NSString stringWithFormat:@"%@%@%@",@"订票热线：",[self.detailItem objectForKey:@"telephone"], @"\n"];
    self.detailIntroduction = [NSString stringWithFormat:@"%@%@%@%@\n%@",show_time,address,price, telephone,[self.detailItem objectForKey:@"introduction"]];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setIntroductionTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
