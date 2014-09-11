//
//  RegisterViewController.h
//  uSav-newUI
//
//  Created by Luca on 2/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGDUtilities.h"
#import "GDataXMLNode.h"
#import "USAVClient.h"
#import "API.h"
#import "TYDotIndicatorView.h"

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *WelcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *GetStartedLabel;
@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *ConfirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *RegisterButton;
@property (weak, nonatomic) IBOutlet UIButton *BackButton;

- (IBAction)BackClick:(id)sender;
- (IBAction)RegisterClick:(id)sender;

- (IBAction)UsernameBeginEdit:(id)sender;
- (IBAction)UsernameEndEdit:(id)sender;
- (IBAction)PasswordBeginEdit:(id)sender;
- (IBAction)ConfirmPasswordBeginEdit:(id)sender;
- (IBAction)PasswordEndEdit:(id)sender;
- (IBAction)ConfirmPasswordEndEdit:(id)sender;

@end
