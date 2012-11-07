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
+ (BOOL) insertCalendar: (NSDictionary *)data;
+ (BOOL) insertCategory:(NSDictionary*)data;
+ (BOOL) updateCategoryId:(NSDictionary*)data;
+ (NSInteger)  selectLatestId:(NSString*) tableName;
+ (BOOL) insertNews: (NSDictionary *)newsData;
+ (NSArray *) selectNews:(int)categoryId;
+ (NSArray *)selectNewsWithoutCategory;
+ (BOOL) updateRead:(NSInteger)show_id;
+ (BOOL) createTable:(NSString *) tableName crtSql:(NSString *)crtSql;
+ (BOOL) deleteTable:(NSString *) tableName crtSql:(NSString *)crtSql;
+ (NSArray *) selectComments:(int)show_id;

+ (BOOL) insertUser:(NSDictionary *)data;
+ (BOOL) updateUser:(NSDictionary *)data;
+ (NSMutableDictionary *) selectUser:(NSString *)UUID;
+ (NSInteger) selectLatestCommentId;
+ (BOOL) insertComment:(NSDictionary*)data;
+ (BOOL) isExistColumn:(NSString *)table columnName:(NSString *)columnName;
+ (BOOL) addColumn:(NSString *)table columnName:(NSString *)columnName type:(NSString *)type defaultValue:(NSString *)defaultValue;
+ (NSString *)selectImageName:(int)categoryId;
+ (NSArray *)selectCategory;
@end
