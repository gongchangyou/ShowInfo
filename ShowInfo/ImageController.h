//
//  ImageController.h
//  ShowInfo
//
//  Created by penglijun on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface ImageController : NSObject
+ (void)request4img:(NSString *)imageName;
+ (NSString *)getPathToImage:(NSString *)imageFile;
+ (UIImage *)getUIImage:(NSString *)imageFile;
@end
