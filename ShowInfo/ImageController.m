//
//  ImageController.m
//  ShowInfo
//
//  Created by penglijun on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageController.h"

@implementation ImageController
+ (void)request4img:(NSString *)imageName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@",@"http://shownews-poster.stor.sinaapp.com/",imageName];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.tag = 1;
    [request setDelegate:self];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSData *img = [request responseData];
        NSString *imgFile = [ImageController getPathToImage:imageName];
        [img writeToFile: imgFile atomically: NO];
    }
}
+ (NSString *)getPathToImage:(NSString *)imageFile
{
    //NSString *imgFile = @"sci.gif";
    imageFile = ([imageFile isEqualToString:@""] || imageFile ==nil) ? @"sci.gif" : imageFile;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *img = [documentsDirectory stringByAppendingPathComponent:imageFile];
    
    return img;
}
+ (NSString *)getPathToExistImage:(NSString *)imageFile
{
    imageFile = ([imageFile isEqualToString:@""] || imageFile ==nil) ? @"sci.gif" : imageFile;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *img = [documentsDirectory stringByAppendingPathComponent:imageFile];
    if([[NSFileManager defaultManager] fileExistsAtPath:img])
        return img;
    else{
        return [documentsDirectory stringByAppendingPathComponent:@"sci.gif"];
    }
}

@end
