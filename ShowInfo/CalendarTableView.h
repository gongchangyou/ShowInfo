//
//  CalendarTableView.h
//  ShowInfo
//
//  Created by penglijun on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UATitledModalPanel.h"
#import "SQLite.h"
@class CalendarTableView;
@protocol CalendarTableViewDelegate
@optional
- (void)showDetail:(NSDictionary *)showData;

@end
@interface CalendarTableView : UATitledModalPanel<UITableViewDataSource,UITableViewDelegate>
{
	UITableView			*tv;
	IBOutlet UIView	*viewLoadedFromXib;
}
@property(nonatomic, retain) NSMutableArray * showList;
@property (nonatomic, retain) IBOutlet UIView *viewLoadedFromXib;
@property (nonatomic, assign) NSObject<CalendarTableViewDelegate>	*calendarTableViewDelegate;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
@end
