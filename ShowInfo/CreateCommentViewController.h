//
//  CreatCommentViewController.h
//  ShowInfo
//
//  Created by 龚畅优 on 12-11-3.
//
//

#import <UIKit/UIKit.h>
#import "ImageController.h"
#import "SQLite.h"
#import <QuartzCore/QuartzCore.h>
#import "RSTapRateView.h"

@class TPKeyboardAvoidingScrollView;
@interface CreateCommentViewController : UIViewController<UITextFieldDelegate,RSTapRateViewDelegate>{

    TPKeyboardAvoidingScrollView *scrollView;
    UITextField *txtIggle;
}
@property (strong, nonatomic) NSDictionary* detailItem;
@property (retain, nonatomic) NSArray * commentList;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIView *rateView;
@property (nonatomic, retain) RSTapRateView *tapRateView;
@property (nonatomic) NSInteger star;
@property (retain, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (retain, nonatomic)NSString *UUID;
-(IBAction)addComment:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

-(IBAction)textFieldDidBeginEditing:(id)sender;
@end
