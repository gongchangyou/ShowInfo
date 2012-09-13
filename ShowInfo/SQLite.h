//
//  SQLite.h
//  ChinaIdioms
//
//  Created by wei.li on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "JSONKit.h"


@interface SQLite : NSObject

+ (NSInteger)  selectLatestId;
+ (BOOL) insertNews: (NSDictionary *)newsData;
+ (NSArray *) selectNews;
@end
