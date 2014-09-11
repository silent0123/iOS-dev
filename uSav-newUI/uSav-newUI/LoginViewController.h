//
//  LoginViewController.h
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"
#import "USAVClient.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"
#import "API.h"
#import "WarningView.h"
#import "USAVLock.h"
#import "TYDotIndicatorView.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *TopLabel;
@property (weak, nonatomic) IBOutlet UILabel *ULabel;
@property (weak, nonatomic) IBOutlet UILabel *SavLabel;
@property (weak, nonatomic) IBOutlet UILabel *VersionLabel;

@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UIButton *SigninButton;
@property (weak, nonatomic) IBOutlet UIButton *SignupButton;


- (IBAction)SigninClick:(id)sender;
- (IBAction)SignupClick:(id)sender;
- (IBAction)ForgetClick:(id)sender;

- (IBAction)UsernameBeginEditing:(id)sender;
- (IBAction)UsernameEndEditing:(id)sender;
- (IBAction)PasswordBeginEditing:(id)sender;
- (IBAction)PasswordEndEditing:(id)sender;


@end
