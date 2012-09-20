//
//  MasterViewController.h
//  ShowInfo
//
//  Created by penglijun on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLite.h"
#import "ASIFormDataRequest.h"
#import "ImageController.h"
#import "EGORefreshTableHeaderView.h"
#import "iToast.h"
@interface MasterViewController : UITableViewController<EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (retain, nonatomic) NSArray * newsList;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;
@end
