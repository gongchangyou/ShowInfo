//
//  CalendarViewController.h
//  ShowInfo
//
//  Created by penglijun on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VRGCalendarView.h"
#import "UATitledModalPanel.h"
#import "SQLite.h"
@interface CalendarViewController : UIViewController <VRGCalendarViewDelegate>

@property (retain, nonatomic) NSMutableDictionary * isShowDay;
@property (retain, nonatomic) NSMutableArray * showCalendar;
@property (retain, nonatomic) IBOutlet UIView *calendarView;
@end
