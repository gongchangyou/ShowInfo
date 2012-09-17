//
//  CalendarViewController.m
//  ShowInfo
//
//  Created by penglijun on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalendarViewController.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController
@synthesize calendarView;
@synthesize showCalendar;
@synthesize isShowDay;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.showCalendar =(NSMutableArray *) [SQLite selectCalendar];
    self.isShowDay = [[NSMutableDictionary alloc] init];
    for (NSDictionary *showDay in self.showCalendar) {
        [self.isShowDay setValue:[NSNumber numberWithBool:YES] forKey:[showDay objectForKey:@"day"]];
    }
    
    
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate=self;
    [calendarView addSubview:calendar];
    //[self.view addSubview:calendar];    
}

-(void)calendarView:(VRGCalendarView *)VRGCalendarView switchedToYear:(int)year switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    for (NSDictionary *eachShowCalendar in self.showCalendar){
        NSString * day = [eachShowCalendar objectForKey:@"day"];
        NSArray * dayAry = [day componentsSeparatedByString:@"-"];
        if([[dayAry objectAtIndex:0] intValue] == year && [[dayAry objectAtIndex:1] intValue] == month){
            [dates addObject:[NSNumber numberWithInt: [[dayAry objectAtIndex:2] intValue]]];
        }
    }
    if ([dates count]) {
        [VRGCalendarView markDates:dates];
    }    
}


- (NSString *)GMTtoLocalDate:(NSDate *) date
{
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localDate = [date  dateByAddingTimeInterval: interval];  
    
    return [[NSString stringWithFormat:@"%@",localDate] substringWithRange:NSMakeRange(0,10)];

}


-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date point: (CGPoint) point
{
    //NSLog(@"Selected date = %@",date);
    NSString *day = [self GMTtoLocalDate:date];
    NSLog(@"Selected date = %@",day);
    //弹出视图显示该日的所有表演
    if ([self.isShowDay objectForKey:day]) {//有表演
        CalendarTableView *modalPanel = [[[CalendarTableView alloc] initWithFrame:self.view.bounds title:day ] autorelease];
        modalPanel.calendarTableViewDelegate = self;
        
        [self.view addSubview:modalPanel];

        [modalPanel showFromPoint:point];
        
    }
}

- (void) showDetail:(NSDictionary *)showData
{
    [self performSegueWithIdentifier:@"ShowDetail" sender:showData];
    //[[segue destinationViewController] setDetailItem:news];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)showData
{
    if ([[segue identifier] isEqualToString:@"ShowDetail"]) {
        //NSDictionary *news = [self.newsList objectAtIndex:indexPath.row];
        [(DetailViewController *)[segue destinationViewController] setDetailItem:showData];
    }
}
- (void)viewDidUnload
{
    [self setCalendarView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [calendarView release];
    [super dealloc];
}
@end
