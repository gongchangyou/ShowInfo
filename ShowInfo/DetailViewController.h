//
//  DetailViewController.h
//  ShowInfo
//
//  Created by penglijun on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageController.h"
@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDictionary* detailItem;

@property (retain, nonatomic) IBOutlet UITextView *introductionTextView;
@property (retain, nonatomic)NSString * posterName;
@end
