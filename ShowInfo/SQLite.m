//
//  SQLite.m
//  ChinaIdioms
//
//  Created by wei.li on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SQLite.h"
//sqlite trace setting?callback?

@interface SQLite ()

+ (sqlite3 *) open;
+ (void) close;
@end

void trace_callback( void* udp, const char* sql ) { printf("{SQL} [%s]\n", sql); }


@implementation SQLite


+ (sqlite3 *) open
{
    static sqlite3 *DBCONN = nil;
    //NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cidiom.sqlite3"];
    
    //NSString *dbPath = @"/Users/penglijun/Applications/ChinaIdioms/cidiom.sqlite3";
    //NSString *dbPath = [NSString stringWithFormat:@"%@/cidiom.1.2.sqlite3", NSHomeDirectory()];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"showInfo.sqlite3"];
    //DLog(@"%@", dbPath);
    const char *dbpath = [dbPath UTF8String]; 
    if (DBCONN == nil && sqlite3_open(dbpath, &DBCONN) != SQLITE_OK)
    {
        NSLog(@"can't open db?");
        return NO;
    }
    sqlite3_trace(DBCONN, trace_callback, NULL);
    return DBCONN;
}

+ (void) close
{
    return;
}
+(NSArray *)selectShowByDay:(NSString *)day
{
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id, show_id, day from calendar where day = ?";
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_text(stmt, 1, [day UTF8String], -1, NULL);

    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]
                    forKey:@"id"];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 1)]
                    forKey:@"show_id"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]
                    forKey:@"day"];
            [list addObject:dic];
            //DLog(@"game is %@", dic);
            [dic release];
        }
        return [NSArray arrayWithArray:list];
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil; 
}
+(NSArray *)selectCalendar
{
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id, show_id, day from calendar order by day asc";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]
                    forKey:@"id"];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 1)]
                    forKey:@"show_id"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]
                    forKey:@"day"];
            [list addObject:dic];
            //DLog(@"game is %@", dic);
            [dic release];
        }
        return [NSArray arrayWithArray:list];
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil; 
}
+ (BOOL) insertCalendar:(NSDictionary*)data
{   sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "insert into calendar (id, show_id, day) values (?,?,?)" ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    NSInteger i=1;
    
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"id"] intValue]);
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"show_id"] intValue]);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"day"] UTF8String], -1, NULL);
    
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to insert into games?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}
+ (BOOL) insertCategory:(NSDictionary*)data
{   sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "insert into category (id, name) values (?,?)" ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    NSInteger i=1;
    
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"id"] intValue]);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"name"] UTF8String], -1, NULL);
    
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to insert into category?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}
+ (BOOL) updateCategoryId:(NSDictionary*)data
{   sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "update show_info set categoryId=? where id=?" ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    NSInteger i=1;
    
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"id"] intValue]);
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"categoryId"] intValue]);
   
    
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to update categoryId?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}

+(NSInteger) selectLatestId:(NSString *)tableName
{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    
    NSString *sql = [NSString stringWithFormat:@"select max(id) as id from %@", tableName];
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            return sqlite3_column_int(stmt, 0);
        }
    } else {
        
    }
    return 0;
}

+ (BOOL) insertNews:(NSDictionary*)data
{   sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "insert into show_info (id, title, address, show_time, price, telephone, introduction, create_time, url, report_date, report_media, image_name, poster_name,read,categoryId) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    NSInteger i=1;
    
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"id"] intValue]);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"title"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"address"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"show_time"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"price"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"telephone"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"introduction"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"create_time"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"url"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"report_date"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"report_media"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"image_name"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"poster_name"] UTF8String], -1, NULL);
    sqlite3_bind_int(stmt,  i++, 0);
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"categoryId"] intValue]);
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to insert into games?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't insert table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}
+ (BOOL) insertComment:(NSDictionary*)data
{   sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "insert into comment (id, from_id, from_name, to_id, to_name, show_id, comment, star, create_time) values (?,?,?,?,?,?,?,?,?)" ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    NSInteger i=1;
    
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"id"] intValue]);
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"from_id"] intValue]);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"from_name"] UTF8String], -1, NULL);
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"to_id"] intValue]);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"to_name"] UTF8String], -1, NULL);
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"show_id"] intValue]);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"comment"] UTF8String], -1, NULL);
    sqlite3_bind_int(stmt,  i++, [[data objectForKey:@"star"] intValue]);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"create_time"] UTF8String], -1, NULL);
    
    
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to insert into comment?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't insert table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}


+ (NSDictionary *) selectShowById:(int)show_id
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id, title, address, show_time, price, telephone, introduction, url,report_date,report_media,image_name, poster_name, read from show_info where id = ?";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_int(stmt, 1, show_id);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
           
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]
                    forKey:@"id"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)]
                    forKey:@"title"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]
                    forKey:@"address"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)]
                    forKey:@"show_time"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)]
                    forKey:@"price"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)]
                    forKey:@"telephone"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)]
                    forKey:@"introduction"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)]
                    forKey:@"url"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)]
                    forKey:@"report_date"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 9)]
                    forKey:@"report_media"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 10)]
                    forKey:@"image_name"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 11)]
                    forKey:@"poster_name"];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 12)]
                    forKey:@"read"];
            

        }
        return dic;
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil;
    
    
}
+ (NSArray *)selectNewsWithoutCategory
{
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id from show_info where categoryId=0 or categoryId='' order by id desc";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]
                    forKey:@"id"];
            [list addObject:dic];
            
            [dic release];
        }
        return [NSArray arrayWithArray:list];
    } else {
        NSLog(@"can't select table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil;
}
+(NSArray *)selectNews:(int)categoryId
{
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id, title, address, show_time, price, telephone, introduction, url,report_date,report_media,image_name,poster_name,read from show_info where categoryId=? order by id desc";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_int(stmt, 1, categoryId);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]
                    forKey:@"id"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)]
                    forKey:@"title"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]
                    forKey:@"address"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)]
                    forKey:@"show_time"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)]
                    forKey:@"price"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)]
                    forKey:@"telephone"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)]
                    forKey:@"introduction"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)]
                    forKey:@"url"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)]
                    forKey:@"report_date"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 9)]
                    forKey:@"report_media"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 10)]
                    forKey:@"image_name"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 11)]
                    forKey:@"poster_name"];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 12)]
                    forKey:@"read"];
            
            [list addObject:dic];
            //DLog(@"game is %@", dic);
            [dic release];
        }
        return [NSArray arrayWithArray:list];
    } else {
        NSLog(@"can't select table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil;
}
+ (BOOL) updateRead:(NSInteger)show_id
{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "update show_info set read = 1 where id = ? " ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    sqlite3_bind_int(stmt, 1, show_id);
    
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to update [show_info]?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}

+ (BOOL) createTable:(NSString *) tableName crtSql:(NSString *)crtSql
{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select count(*) from sqlite_master where name=?";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_text(stmt, 1, [tableName UTF8String], -1, NULL);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            if (sqlite3_column_int(stmt, 0)) {
                NSLog(@"has table %@", tableName);
            }else{
                
                NSInteger res = sqlite3_prepare_v2(DBCONN, [crtSql UTF8String], -1, &stmt, NULL);
                if( res == SQLITE_OK) {
                    if (sqlite3_step(stmt) != SQLITE_DONE)
                    {
                        NSLog(@"fail to create table %@",tableName);
                    } else {
                        NSLog(@"create table %@ success",tableName);
                        return YES;
                    }
                } else {
                    NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
                }
                
            }
        }
       
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}
+ (BOOL) deleteTable:(NSString *) tableName crtSql:(NSString *)delSql
{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select count(*) from sqlite_master where name=?";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_text(stmt, 1, [tableName UTF8String], -1, NULL);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            if (sqlite3_column_int(stmt, 0)) {
                NSLog(@"has table %@", tableName);
                NSInteger res = sqlite3_prepare_v2(DBCONN, [delSql UTF8String], -1, &stmt, NULL);
                if( res == SQLITE_OK) {
                    if (sqlite3_step(stmt) != SQLITE_DONE)
                    {
                        NSLog(@"fail to delete table %@",tableName);
                    } else {
                        NSLog(@"delete table %@ success",tableName);
                        return YES;
                    }
                } else {
                    NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
                }
            }else{              
                
            }
        }
        
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}
+(NSArray *)selectComments:(int)show_id
{
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id, from_id, from_name, to_id, to_name, show_id, comment,star, create_time from comment where show_id=? order by id desc";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_int(stmt, 1, show_id);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            int i=0;
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i++)]
                    forKey:@"id"];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i++)]
                    forKey:@"from_id"];
            if ((char *)sqlite3_column_text(stmt, i)) {
                [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i++)]
                        forKey:@"from_name"];
            }else{
                i++;
                [dic setObject:@"" forKey:@"from_name"];
            }
            
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i++)]
                    forKey:@"to_id"];
            if ((char *)sqlite3_column_text(stmt, i)) {
                [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i++)]
                        forKey:@"to_name"];
            }else{
                i++;
                [dic setObject:@"" forKey:@"to_name"];
            }
            
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i++)]
                    forKey:@"show_id"];
            if ((char *)sqlite3_column_text(stmt, i)) {
                [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i++)]
                        forKey:@"comment"];
            }else{
                i++;
                [dic setObject:@"" forKey:@"comment"];
            }
            
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i++)]
                    forKey:@"star"];
            if ((char *)sqlite3_column_text(stmt, i)) {
                [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i++)]
                        forKey:@"creat_time"];
            }else{
                i++;
                [dic setObject:@"" forKey:@"creat_time"];
            }
                        
            [list addObject:dic];
            //DLog(@"game is %@", dic);
            [dic release];
        }
        return [NSArray arrayWithArray:list];
    } else {
        NSLog(@"can't select table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil;
}
+ (BOOL) insertUser:(NSDictionary *)data{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "insert into user (UUID, name) values (?,?)" ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    NSInteger i=1;
    
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"UUID"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"name"] UTF8String], -1, NULL);

    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to insert into user?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't insert table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
    return true;
}
+ (BOOL) updateUser:(NSDictionary *)data{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    const char *sql = "update user set name=? where UUID=?" ;
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    NSInteger i=1;
    
    
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"name"] UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, i++, [[data objectForKey:@"UUID"] UTF8String], -1, NULL);
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to update user?");
        } else {
            return YES;
        }
    } else {
        NSLog(@"can't insert table? %s", sqlite3_errmsg(DBCONN));
    }
    return true;
}
+ (NSMutableDictionary *) selectUser:(NSString *)UUID{
    
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id, UUID, name from user where UUID=? order by id desc";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_text(stmt, 1, [UUID UTF8String], -1, NULL);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
           
            int i = 0;
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i++)] forKey:@"id"];
            if ((char *)sqlite3_column_text(stmt, i)) {
                [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i++)]
                        forKey:@"UUID"];
            }else{
                i++;
                [dic setObject:@"" forKey:@"UUID"];
            }
            if ((char *)sqlite3_column_text(stmt, i)) {
                [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i++)]
                        forKey:@"name"];
            }else{
                i++;
                [dic setObject:@"" forKey:@"name"];
            }
        }
    }
    return dic;
}
+(NSInteger) selectLatestCommentId
{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    char *sql = "select max(id) as id from comment" ;
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, sql, -1, &stmt, NULL);
    
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            return sqlite3_column_int(stmt, 0);
        }
        //DLog(@"empty table [game_list]?");
    } else {
        //DLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return 0;
}
+ (BOOL) isExistColumn:(NSString *)table columnName:(NSString *)columnName{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@", columnName, table];
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            return YES;
        }
        return YES;
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
        return NO;
    }
}
+ (BOOL) addColumn:(NSString *)table columnName:(NSString *)columnName type:(NSString *)type defaultValue:(NSString *)defaultValue{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add Column %@ %@ default %@", table, columnName, type, defaultValue];
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    if( res == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"fail to add column %@ table %@",columnName,table);
        } else {
            NSLog(@"create column %@ success",columnName);
            return YES;
        }
    } else {
        NSLog(@"can't open table? %s", sqlite3_errmsg(DBCONN));
    }
    return NO;
}

+ (NSArray *)selectCategory{
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select id,name from category order by id asc";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]
                    forKey:@"id"];
            [dic setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)]
                    forKey:@"name"];
            [list addObject:dic];
            [dic release];
        }
        return [NSArray arrayWithArray:list];
    } else {
        NSLog(@"can't select table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil;
}

+ (NSString *)selectImageName:(int)categoryId{
    sqlite3 *DBCONN = [self open];
    sqlite3_stmt    *stmt;
    NSString *sql = @"select image_name  from show_info where categoryId=? order by id desc limit 1";
    
    NSInteger res = sqlite3_prepare_v2(DBCONN, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_bind_int(stmt, 1, categoryId);
    if( res == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            return [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        }
    } else {
        NSLog(@"can't select table? %s", sqlite3_errmsg(DBCONN));
    }
    return nil;
}
@end
