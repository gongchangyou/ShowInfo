//
//  CategoryViewController.h
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-7.
//
//

#import <UIKit/UIKit.h>
#import "SQLite.h"
#import "ImageController.h"
@protocol categoryViewControllerDelegate
-(void)turnToMasterView:(UIButton *)sender;
@end
@interface CategoryViewController : UIViewController{
    id<categoryViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id<categoryViewControllerDelegate> delegate;
@property(nonatomic,retain)NSArray *categoryList;
@end
