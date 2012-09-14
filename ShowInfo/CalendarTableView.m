//
//  CalendarTableView.m
//  ShowInfo
//
//  Created by penglijun on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalendarTableView.h"
#define BLACK_BAR_COMPONENTS				{ 0.22, 0.22, 0.22, 1.0, 0.07, 0.07, 0.07, 1.0 }
@implementation CalendarTableView
@synthesize viewLoadedFromXib,showList;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title{
	if ((self = [super initWithFrame:frame])) {
		
		CGFloat colors[8] = BLACK_BAR_COMPONENTS;
		[self.titleBar setColorComponents:colors];
		self.headerLabel.text = title;

		
		tv = [[[UITableView alloc] initWithFrame:CGRectZero] autorelease];
		[tv setDataSource:self];
		
		
		//[[NSBundle mainBundle] loadNibNamed:@"UAExampleView" owner:self options:nil];
		self.showList = [[NSMutableArray alloc] init];
        NSArray *showIds = [SQLite selectShowByDay:title];
        for (NSDictionary *show in showIds) {
            int show_id = [[show objectForKey:@"show_id"] intValue];
            [self.showList addObject:[SQLite selectShowById:show_id]];
            
        }
		[self.contentView addSubview:tv];
        
		
	}	
	return self;
}

- (void)dealloc {
    [tv release];
	[viewLoadedFromXib release];
    [super dealloc];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[tv setFrame:self.contentView.bounds];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.showList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = @"UAModalPanelCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
    NSDictionary *show = [self.showList objectAtIndex:indexPath.row];
	NSString *title = [show objectForKey:@"title"];
	[cell.textLabel setText:[NSString stringWithFormat:@"%@", title]];
	
	return cell;
}



@end
