//
//  CalendarTableView.h
//  ShowInfo
//
//  Created by penglijun on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UATitledModalPanel.h"
#import "SQLite.h"
@interface CalendarTableView : UATitledModalPanel<UITableViewDataSource,UITableViewDelegate>
{
	UITableView			*tv;
	IBOutlet UIView	*viewLoadedFromXib;
}
@property(nonatomic, retain) NSMutableArray * showList;
@property (nonatomic, retain) IBOutlet UIView *viewLoadedFromXib;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
@end
