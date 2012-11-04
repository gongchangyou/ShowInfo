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
+ (NSDictionary *) selectShowById:(int)show_id;
+ (NSArray *) selectShowByDay: (NSString *)day;
+ (NSArray *) selectCalendar;
+ (BOOL) insertCalendar: (NSDictionary *)calendarData;
+ (NSInteger)  selectLatestId;
+ (BOOL) insertNews: (NSDictionary *)newsData;
+ (NSArray *) selectNews;
+ (BOOL) updateRead:(NSInteger)show_id;
+ (BOOL) createTable:(NSString *) tableName crtSql:(NSString *)crtSql;
+ (BOOL) deleteTable:(NSString *) tableName crtSql:(NSString *)crtSql;
+ (NSArray *) selectComments:(int)show_id;

+ (BOOL) insertUser:(NSDictionary *)data;
+ (BOOL) updateUser:(NSDictionary *)data;
+ (NSMutableDictionary *) selectUser:(NSString *)UUID;
@end
