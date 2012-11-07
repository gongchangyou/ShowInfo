//
//  AppDelegate.m
//  ShowInfo
//
//  Created by penglijun on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SQLite.h"
@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    // Override point for customization after application launch.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"showInfo.sqlite3"];
    
    if ([fileManager fileExistsAtPath:dbPath] == NO) {
        //first launch
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"showInfo" ofType:@"sqlite3"];
        [fileManager copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    [SQLite createTable:@"user" crtSql:@"create table user (id integer primary key autoincrement, UUID text,name text)"];
    NSString *UUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ShowInfo_UUID"];
    if (UUID == nil) {
        UUID =  (NSString *)CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
        [[NSUserDefaults standardUserDefaults] setValue:UUID forKey:@"ShowInfo_UUID"];
        NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:UUID,@"UUID", nil];
        [SQLite insertUser:dict];
        [dict release];
    }
    
    [SQLite createTable:@"comment" crtSql:@"create table comment (id integer primary key autoincrement, from_id int,from_name text, to_id int,to_name text,show_id int,comment text,star int, create_time text)"];
    [SQLite createTable:@"category" crtSql:@"create table category (id integer primary key autoincrement, name text)"];
    if(![SQLite isExistColumn:@"show_info" columnName:@"categoryId"]){
        [SQLite addColumn:@"show_info" columnName:@"categoryId" type:@"int" defaultValue:@"0"];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
