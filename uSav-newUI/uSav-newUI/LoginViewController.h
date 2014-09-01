//
//  LoginViewController.h
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *ULabel;
@property (weak, nonatomic) IBOutlet UILabel *SavLabel;

@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UIButton *SigninButton;
@property (weak, nonatomic) IBOutlet UIButton *SignupButton;


- (IBAction)SigninClick:(id)sender;
- (IBAction)SignupClick:(id)sender;
- (IBAction)ForgetClick:(id)sender;

//输入框变化，上移界面
- (IBAction)UsernameEditBegin:(id)sender;
- (IBAction)PasswordEditBegin:(id)sender;

@end
