//
//  USAVLoginViewController.h
//  uSav
//
//  Created by young dennis on 3/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>


@class USAVLoginViewController;

@protocol USAVLoginViewControllerDelegate <NSObject>
-(void)loginResult:(BOOL)success
            target:(USAVLoginViewController *)sender;
-(void)loginCancelled:(USAVLoginViewController *)sender;
@end

@interface USAVLoginViewController : UIViewController
<UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id <USAVLoginViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *txtPassRecv;


@property (weak, nonatomic) IBOutlet UITextField *userNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *ReEmail;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *askToRegisterBtn;
@property (weak, nonatomic) IBOutlet UILabel *displayPwLabel;
@property (weak, nonatomic) IBOutlet UITextField *userEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *displayPwBtn;
@property (weak, nonatomic) IBOutlet UITextField *reenterPwTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginRegBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;

@property (weak, nonatomic) IBOutlet UITextField *securityQuestionTextField;
@property (weak, nonatomic) IBOutlet UITextField *securityAnswerTextField;

@property (weak, nonatomic) IBOutlet UIButton *displayCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *dispalyLabel;

@property (strong, nonatomic) NSDictionary *loginObj;
@property (strong, nonatomic) NSString *autologinFailMsg;

@property (weak, nonatomic) IBOutlet UIButton *btnForgetPassword;


- (IBAction)displayPasswordBtnPressed:(id)sender;
- (IBAction)askToRegisterBtnPressed:(id)sender;
- (IBAction)loginRegBtnPressed:(id)sender;
- (IBAction)cancelBtnPressed:(id)sender;


#pragma mark 帐号状态检测
- (void)loginStatusCheckForAccount:(NSString *)email andPassword:(NSString *)password;
@end
